/* Offer */
results.Offer = function(el) {
    this.el = el.data('offer', this);
};
results.Offer.prototype = {
parseVariants: function(selector) {
    var that = this;
    var prices = $.parseJSON(this.el.attr('data-prices'));
    this.variants = [];
    this.el.find(selector).each(function(i) {
        var el = $(this);
        var fstr = el.attr('data-features');
        var features = fstr.split(' ').toIndex();
        if (!features.nonstop) {
            features.ldur = Number(el.attr('data-layover'));
            fstr += ' ldur' + Math.floor(features.ldur / 60);
        }
        features.all = fstr;
        if (features.onestop && features.ldur < 121) {
            features.optimal = true;
        }
        that.variants[i] = {
            offer: that,
            price: prices['RUR'],
            price_pure: prices['RUR_pure'],
            id: el.text(),
            duration: Number(el.attr('data-duration')),
            segments: el.attr('data-segments').split(' '),
            dpttimes: el.attr('data-dpttimes'),
            features: features,
        };
    });
},
parseSegments: function() {
    var summaries = {};
    summaries.all = this.el.find('.os-summary').each(function() {
        var el = $(this);
        summaries[el.attr('data-flights')] = el;
    });
    this.summaries = summaries;
},
addBook: function() {
    this.book = results.bookTemplate.clone().appendTo(this.el);
    this.btitle = this.book.find('.obb-title');
    this.state = this.book.find('.ob-state');
},
updateBook: function() {
    var p = this.selected.price;
    var ap = results.data.averagePrice;
    var pp = this.selected.price_pure; 
    var state = [];
    if (p < ap) {
        var percents = Math.round((ap - p) / ap * 100);
        if (percents > 3 && percents <= 20) {
            state.push(I18n.t('offer.price.average', {value: percents.toFixed(1).replace('.0', '') + '%'}));
        }
        if (percents > 20) {
            state.push(I18n.t('offer.price.average', {value: percents + '%'}));
        }
    }
    if (p < pp) {
        state.push(I18n.t('offer.price.carrier', {value: pp - p}));
    }
    var price = decoratePrice(I18n.t('currencies.RUR', {count: p}));    
    this.btitle.html(results.priceTemplate.absorb(price));
    if (state.length) {
        this.state.html('<div class="obst-wrapper"><table class="obs-table"><tr><td>' + results.stateTemplate + '</td><td class="obs-profit">' +  state.join('<br>') + '</td></tr></table></div>');
    } else {
        this.state.html(results.stateTemplate.replace('<br>', ' '));
    }
},
select: function(index, smooth) {
    this.summaries.all.removeClass('os-selected');
    var variant = this.variants[index];
    for (var i = variant.segments.length; i--;) {
        this.summaries[variant.segments[i]].addClass('os-selected');
    }
    this.selected = variant;
    this.book.removeClass('ob-disabled ob-failed');
    if (smooth) {
        var that = this;
        var button = this.book.find('.ob-button');
        button.animate({opacity: 0}, 150);
        button.queue(function(next) {
            that.updateBook();
            next();
        });
        button.delay(100).animate({opacity: 1}, 150);    
    } else {
        this.updateBook();
    }
},
choose: function(segment, code) {
    var matches = [];
    var target = [].concat(this.selected.segments);
    target[segment] = code;
    for (var i = this.variants.length; i--;) {
        var variant = this.variants[i];
        if (variant.improper) continue;
        var precision = 0;
        var segments = variant.segments;
        for (var s = segments.length; s--;) {
            if (segments[s] === target[s]) {
                precision++;
            } else if (s === segment) {
                precision = -10;
            }
        }
        matches.push({
            precision: precision,
            index: i
        });
    }
    var index = matches.sort(function(a, b) {
        if (a.precision > b.precision) return -1;
        if (a.precision < b.precision) return 1;
        return a.index - b.index;
    })[0].index;
    this.select(index, this.selected.price !== this.variants[index].price);
},
selectSegment: function(segment, flights) {
    this.choose(segment, flights);
    this.showCompatible();
    this.otherSegments();
    this.otherCarriers();
    if (this.prices && this.prices.different) {
        this.otherPrices();
    }
    if (this.details && this.details.is(':visible')) {
        this.updateDetails();
    }
    if (this.large) {
        this.updateExcess();
    }
    if (this.complex) {
        results.fixed.move();
    }
},
showCompatible: function() {
    var variants = this.variants;
    var selected = this.selected.segments;
    var compatible = {}, sl = selected.length;
    for (var s = sl; s--;) {
        compatible[selected[s]] = true;
    }
    for (var v = variants.length; v--;) {
        var segments = variants[v].segments;
        var different = [];
        for (var s = sl; s--;) {
            if (segments[s] !== selected[s]) different.push(segments[s]);
        }
        if (different.length === 1) {
            compatible[different[0]] = true;
        }
    }
    this.summaries.all.each(function() {
        var el = $(this);
        el.toggleClass('os-disabled', !compatible[el.attr('data-flights')]);
    });
    //this.sortSegments();
},
sortSegments: function() {
    this.el.find('.o-segment').each(function() {
        var segment = $(this), items = [];
        var sorting = function(a, b) {
            return (b.selected - a.selected) || (a.disabled - b.disabled) || (a.dpt - b.dpt);
        };
        segment.find('.os-summary').each(function(i) {
            var el = $(this);
            items[i] = {
                el: el,
                selected: el.hasClass('os-selected') ? 1 : 0,
                disabled: el.hasClass('os-disabled') ? 1 : 0,
                dpt: Number(el.attr('data-dpt'))
            };
        });
        items = items.sort(sorting);
        for (var i = items.length; i--;) {
            items[i].el.prependTo(segment);
        }
    });
},
otherSegments: function() {
    this.el.find('.oss-incompatible').remove();
    this.el.find('.o-segment').each(function(i) {
        var disabled = $(this).find('.os-disabled');
        if (disabled.length) {
            disabled.find('.oss-parts').append('<p class="oss-incompatible">' + results.data.ostitles[i] + '</p>');
        }
    });
},
countPrices: function() {
    var sl = this.selected.segments.length;
    var prices = {}, sample;
    for (var v = this.variants.length; v--;) {
        var variant = this.variants[v];
        var price = variant.price;
        for (var s = sl; s--;) {
            var flights = variant.segments[s];
            var range = prices[flights];
            if (range) {
                range.min = Math.min(range.min, price);
                range.max = Math.max(range.max, price);
            } else {
                prices[flights] = {min: price, max: price};
            }
        }
        if (sample === undefined) {
            sample = price;
        } else if (price !== sample) {
            prices.different = true;
        }
        prices[variant.segments.join(' ')] = price;
    }
    this.prices = prices;
},
otherCarriers: function() {
    var that = this;
    this.el.find('.other-carrier').removeClass('other-carrier');
    this.el.find('.o-segment').each(function(s) {
        var selected = that.summaries[that.selected.segments[s]].attr('data-carrier');
        $(this).find('.os-summary').each(function() {
            var el = $(this);
            if (el.attr('data-carrier') !== selected) {
                el.find('.oss-carrier').addClass('other-carrier');
            }
        });
    });
},
otherPrices: function() {
    var prices = this.prices;
    var ss = this.selected.segments
    var sp = this.selected.price;
    this.el.find('.oss-price').remove();
    this.el.find('.oss-different').removeClass('oss-different');
    this.el.find('.o-segment').each(function(s) {
        var segments = [].concat(ss);
        $(this).find('.os-summary').each(function() {
            var el = $(this), value;
            var flights = el.attr('data-flights');
            if (el.hasClass('os-disabled')) {
                value = prices[flights].min;
            } else {
                segments[s] = flights;
                value = prices[segments.join(' ')];
            }
            if (value !== sp) {
                var type = value > sp ? 'rise' : 'fall';
                var absp = I18n.t('currencies.RUR.sign', {value: value.separate()});
                var sample = $('<div class="oss-price"></div>').addClass('ossp-' + type);
                if (ss.length === 1) {
                    el.append(sample.clone().html(absp));
                } else {
                    var relp = I18n.t('offer.price.' + type, {value: I18n.t('currencies.RUR.sign', {value: Math.abs(value - sp).separate()})});
                    el.append(sample.clone().addClass('ossp-rel').html(relp));
                    el.append(sample.clone().addClass('ossp-abs').html(absp));
                }
                el.addClass('oss-different');
            }
        });
    });
},
hideExcess: function(limit) {
    var that = this;
    var segments = [];
    this.el.find('.o-segment').each(function(i) {
        var el = $(this);
        segments[i] = {
            el: el,
            size: el.find('.os-summary').length - 1
        };
    });
    var sl = segments.length, average = limit / sl - 1, total = 0;
    for (var i = sl; i--;) {
        var segment = segments[i];
        segment.part = Math.max(0, segment.size - average);
        total += segment.part;
    }
    var need = this.summaries.all.length - limit, used = 0;
    for (var i = sl; i--;) {
        var segment = segments[i];
        var excess = i === 0 ? (need - used) : Math.round(need * segment.part / total);
        if (excess > 1) {
            var title, amount = I18n.t('offer.segment.variants', {count: excess});
            if (results.data.segments.length === 1) {
                title = '';
            } else if (results.data.segments[1].rt) {
                title = I18n.t(i === 0 ? 'there' : 'back', {scope: 'offer.segment.direction'});
            } else {
                title = results.data.segments[i].arvto;
            }
            var text = I18n.t('offer.segment.more', {amount: amount, direction: title}).replace(/ $/, '');
            var more = '<div class="os-more">' + text + '</div>';
            this.toggleExcess(segment.el.addClass('hide-excess').append(more), excess);
        }
        used += excess;
    }
},
updateExcess: function() {
    var that = this;
    this.el.find('.os-selected').each(function() {
        var el = $(this);
        if (el.hasClass('os-excess')) {
            var segment = el.closest('.o-segment');
            var excess = segment.find('.os-excess').removeClass('os-excess').length;
            that.toggleExcess(segment, excess);
        }
    });
},
toggleExcess: function(segment, amount) {
    var that = this, items = [];
    segment.find('.os-summary:not(.os-selected)').each(function(i) {
        var el = $(this);
        var price = that.prices[el.attr('data-flights')];
        items[i] = {
            el: el,
            price: price.min || price,
            disabled: el.hasClass('os-disabled') ? 1 : 0,
            duration: Number(el.attr('data-duration'))
        };
    });
    items.sort(function(a, b) {
        return (b.disabled - a.disabled) || (b.price - a.price) || (b.duration - a.duration);
    });
    var prices = [];
    for (var i = amount; i--;) {
        var item = items[i];
        item.el.addClass('os-excess');
        prices.push(item.price);
    }
    var pmin = Math.min.apply(Math, prices);
    var pmax = Math.min.apply(Math, prices);
},
updateDetails: function() {
    var offer = this.selected.offer;
    var features = this.selected.features;
    var segments = this.selected.segments;
    var odSegments = $('<div class="od-segments"></div>');
    for (var s = 0, sm = segments.length; s < sm; s++) {
        var content = offer.el.find('.o-segment .os-details[data-flights="' + segments[s] + '"]').clone();
        content.addClass('segment' + (s + 1)).appendTo(odSegments);
    }
    var odComments = $('<div class="od-comments"></div>');
    offer.el.find('.o-comments .od-comment').each(function() {
        var comment = $(this), carrier = comment.attr('data-carrier');
        if (!carrier || features['opcarr' + carrier]) {
            comment.clone().appendTo(odComments);
        }
    });
    var temp = $('<div></div>');
    temp.append(odSegments);
    temp.append(odComments);
    if (results.debug) {
        var debug = offer.el.find('.o-debug[data-segments="' + segments.join(' ') + '"]');
        if (debug.length) {
            odSegments.prepend('<div class="od-debug">' + debug.html() + '</div>');
        }
    }
    if (!this.details) {
        this.details = $('<div class="o-details">').hide().appendTo(this.el);
    }
    this.details.html(temp.html());
},
showDetails: function(instant) {
    var show = this.el.find('.od-show');
    var hide = this.el.find('.od-hide');
    this.updateDetails();
    this.details.slideDown(instant ? 0 : this.details.height(), function() {
        show.hide();
        hide.show();
    });
},
hideDetails: function(instant) {
    var show = this.el.find('.od-show');
    var hide = this.el.find('.od-hide');
    this.details.slideUp(instant ? 0 : this.details.height(), function() {
        hide.hide();
        show.show();
    });
}
};
