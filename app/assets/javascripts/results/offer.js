/* Offer */
results.Offer = function(el) {
    this.el = el.data('offer', this);
};
results.Offer.prototype = {
parseVariants: function(selector) {
    var that = this;
    var price = $.parseJSON(this.el.attr('data-prices'))['RUR'];
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
            price: price,
            id: el.text(),
            duration: Number(el.attr('data-duration')),
            segments: el.attr('data-segments').split(' '),
            features: features
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
    var units = local.currencies.RUR;
    var price = this.selected.price.decline(units[0], units[1], units[2]);
    this.btitle.html(results.priceTemplate.absorb(price));
    this.state.html(results.stateTemplate);
},
select: function(index) {
    this.summaries.all.removeClass('os-selected');
    var variant = this.variants[index];
    for (var i = variant.segments.length; i--;) {
        if (!this.summaries[variant.segments[i]]) {
            console.log(this);
        }
        this.summaries[variant.segments[i]].addClass('os-selected');
    }
    this.selected = variant;
    this.book.removeClass('ob-disabled');    
    this.updateBook();
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
    this.select(matches.sort(function(a, b) {
        if (a.precision > b.precision) return -1;
        if (a.precision < b.precision) return 1;
        return a.index - b.index;
    })[0].index);
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
                var price = $('<div class="oss-price"></div>');
                var key = value > sp ? 'rise' : 'fall';
                var text = results.currencies['RUR'].absorb(Math.abs(value - sp));
                price.html(local.offers.price[key].absorb(text));
                price.addClass('ossp-' + key);
                el.addClass('oss-different').append(price);
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
            var title, amount = excess.decline.apply(excess, local.offers.variants);
            if (results.data.segments.length === 1) {
                title = '';
            } else if (results.data.segments[1].rt) {
                title = local.offers.directions[i];
            } else {
                title = results.data.segments[i].arvto;
            }
            var text = local.offers.more.absorb(amount, title).replace(/ $/, '');
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