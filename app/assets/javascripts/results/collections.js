/* Offers collection */
results.OffersCollection = function(id) {
    this.id = id;
};
results.OffersCollection.prototype = {
abort: function() {
    var r = this.request;
    if (r && r.abort) r.abort();
    delete this.request;
},
load: function(url, data, timeout) {
    var that = this;
    this.loading = true;
    this.request = $.ajax({
        url: url,
        data: data,
        success: function(s, status, request) {
            delete that.loading;
            if (that.request !== request) return;
            that.update(s);
            results.updated();
        },
        error: function(request, status) {
            delete that.loading;
            if (that.request !== request) return;
            that.update('');
            results.updated();
        },
        timeout: timeout
    });
},
parse: function() {
    var offers = [], length = 0;
    this.content.find('.offer').each(function(i) {
        var offer = new results.Offer($(this));
        with (offer) {
            parseVariants('.o-variants > li');
            parseSegments();
            addBook();
            select(0);
        }
        var vl = offer.variants.length;
        if (vl !== 1) {
            offer.showCompatible();
            offer.otherCarriers();
        }
        length += vl;
        offers[i] = offer;
    });
    this.length = length;
    this.offers = offers;
},
filter: function(check) {
    var amount = 0;
    var features = [];
    var offers = this.offers, offer, o, variants, variant, v;
    for (o = offers.length; o--;) {
        offer = offers[o];
        offer.improper = true;
        variants = offer.variants;
        var summaries = {};
        var selected = 0;
        for (v = variants.length; v--;) {
            variant = variants[v];
            if (check(variant.features)) {
                variant.improper = false;
                offer.improper = false;
                var segments = variant.segments;
                for (s = segments.length; s--;) {
                    summaries[segments[s]] = true;
                }
                features.push(variant.features.all);
                selected = v;
                amount++;
            } else {
                variant.improper = true;
            }
        }
        if (offer.improper) {
            offer.el.hide();
        } else {
            offer.summaries.all.each(function() {
                var el = $(this);
                el.toggleClass('os-hidden', !summaries[el.attr('data-flights')]);
            });
            if (offer.selected.improper) {
                offer.select(selected);
                offer.showCompatible();
                offer.otherCarriers();
            }            
            offer.el.show();
        }
    }
    var title;
    if (amount !== this.length) {
        title = local.offers.from.absorb(amount, this.length);
    } else {
        title = local.offers.all.absorb(this.length);
    }
    this.control.html(title);
    results.filters.proper = features.join(' ');
}
};

/* All offers */
results.all = $.extend(new results.OffersCollection('all'), {
update: function(data) {
    var that = this;
    results.queue.add(function() {
        that.content.html(data);
        that.parse();
    });
    results.queue.add(function() {
        results.filters.update();
    });
    results.queue.add(function() {
        that.control.html(local.offers.all.absorb(that.length));
        if (that.offers.length !== 0) {
            results.extendData();
            results.getOfferTemplate();
            results.updateFeatured();
        }
    });
}
});

/* Matrix */
results.matrix = $.extend(new results.OffersCollection('matrix'), {
init: function() {
    var that = this;
    this.table = this.content.find('.rmp-table');
    this.table.delegate('.rmp-item', 'click', function() {
        var index = Number($(this).attr('data-index'));
        that.offer.select(index);
        setTimeout(function() {
            results.changeDates(that.offer.selected.dates);
        }, 20);
    });
    this.updateLabel = results.ComplexOffer.prototype.updateLabel;
},
update: function(data) {
    var that = this;
    results.queue.add(function() {
        that.content.find('.rm-prices').nextAll().remove();
        that.content.find('.offer').append(data);
        if (that.content.find('.rm-source').length) {
            that.control.show();
            that.parse();
        } else {
            that.control.hide();
        }
    });
},
parse: function() {
    var variants = [];
    this.content.find('.rm-variants').each(function() {
        var offer = new results.Offer($(this));
        offer.parseVariants('.rmv-data');
        offer.el.find('.rm-variant').each(function(i) {
            var variant = offer.variants[i];
            variant.el = $(this);
            variant.dates = variant.el.attr('data-dates').split(' ');
            variant.el.find('.os-details').addClass(function(i) {
                return 'segment' + (i + 1);
            });
        });
        variants = variants.concat(offer.variants);
    });
    var that = this;
    var el = this.content.find('.offer');
    this.offer = new results.Offer(el);
    this.offer.variants = variants;
    this.upgradeOffer();
    this.countDates();
    this.showPrices();
    var table = this.table.get(0);    
    var index = Number($(table.rows[4].cells[4]).find('.rmp-item').attr('data-index'));
    this.offer.select(isNaN(index) ? 0 : index);
},
upgradeOffer: function() {
    var that = this;
    this.offer.select = function(index) {
        var offer = this;
        this.selected = this.variants[index];
        that.selectDates(this.selected.dates);
        setTimeout(function() {
            offer.updateDetails();
            offer.updateBook();
        }, 20);
        offer.book.removeClass('ob-disabled');
        booking.abort();
    };
    this.offer.updateDetails = function() {
        var details = this.selected.el.find('.rmv-details');
        this.details.html(details.html());
    };
    this.offer.addBook();
    var book = this.offer.el.find('.o-book');
    book.wrap('<div class="ob-placeholder"></div>');
    book.append('<div class="ob-shadow"></div>');
    this.offer.details = $('<div class="o-details">').appendTo(this.offer.el);
    this.offer.el.find('.od-control').remove();    
},
countDates: function() {
    var table = this.table.get(0);
    var dates = this.content.find('.rm-source').attr('data-dates').split(' ');
    this.cols = {};
    this.rows = {};
    var cd = Date.parseDMY(dates[0]).shift(-4);
    for (var i = 1; i < 8; i++) {
        $(table.rows[0].cells[i]).html(this.humanDate(cd.shift(1), 1));
        this.cols[cd.DMY()] = i;
    }
    if (dates.length === 2) {
        this.table.removeClass('rmpt-ow');
        var rd = Date.parseDMY(dates[1]).shift(-4);
        for (var i = 1; i < 8; i++) {
            $(table.rows[i].cells[0]).html(this.humanDate(rd.shift(1), 2));
            this.rows[rd.DMY()] = i;
        }
    } else {
        this.table.addClass('rmpt-ow');
        this.rows.middle = 4;
    }
},
showPrices: function() {
    var variants = this.offer.variants;
    this.content.find('.rmp-item').remove();
    for (var i = variants.length; i--;) {
        var variant = variants[i];
        var c = this.cols[variant.dates[0]];
        var r = this.rows[variant.dates[1] || 'middle'];
        var item = $('<div class="rmp-item"></div>').attr('data-index', i);
        item.html('<h6 class="rmp-cost"><span class="rmp-sum">' + variant.price + '</span>&nbsp;<span class="ruble">Р</span></h6>');
        item.append(variant.el.find('.rmv-bars').clone());
        $(this.table.get(0).rows[r].cells[c]).append(item);
    }
    this.updateLabel(local.offers.matrix);   
},
humanDate: function(date, segment) {
    var day = date.getDate();
    var month = local.date.gmonthes[date.getMonth()];
    var weekday = local.date.weekdays[(date.getDay() || 7) - 1];
    var pattern = '<h6 class="rmp-date{0}">{1}&nbsp;{2}</h6><p class="rmp-weekday">{3}</p>';
    return pattern.absorb(segment, day, month, weekday);
},
selectDates: function(dates) {
    var c = this.cols[dates[0]];
    var r = this.rows[dates[1] || 'middle'];
    var cell = this.table.get(0).rows[r].cells[c];
    this.table.find('.rmp-selected').removeClass('rmp-selected');
    $(cell).find('.rmp-item').addClass('rmp-selected');
}
});

/* Complex offers */
results.ComplexOffer = function(id) {
    this.id = id;
};
results.ComplexOffer.prototype = {
merge: function(variants) {
    var sl = variants[0].segments.length;
    var offer = new results.Offer(results.offerTemplate.clone());
    var sorting = function(a, b) {
        return a.dpt - b.dpt;
    };
    var titles = ['туда', 'обратно'];
    offer.complex = true;    
    offer.variants = variants;
    offer.el.find('.o-segment').each(function(s) {
        var segment = $(this), items = [], used = {};
        for (var v = variants.length; v--;) {
            var variant = variants[v];
            var flights = variant.segments[s];
            if (!used[flights]) {
                var el = variant.offer.summaries[flights].clone();
                items.push({
                    el: el,
                    dpt: Number(el.attr('data-dpt'))
                });
                used[flights] = true;
            }
        }
        items = items.sort(sorting);
        var rt = results.data.segments.length === 2 && results.data.segments[1].rt;
        var st = rt ? local.offers.stitle.absorb(local.offers.directions[s]) : results.data.segments[s].short
        segment.append($('#ost-template').html().absorb(st));
        if (results.data.segments.length === 1) {
            segment.find('.ostn-text').hide();
        }
        for (var i = 0, im = items.length; i < im; i++) {
            segment.append(items[i].el);
        }
    });
    with (offer) {
        parseSegments();
        addBook();
        select(0);
        showCompatible();
        otherCarriers();
        countPrices();
        otherPrices();
        showDetails(true);
    }
    if (offer.summaries.all.length > results.data.capacity) {
        offer.hideExcess(results.data.capacity);
        offer.large = true;
    }
    offer.el.addClass('o-complex');
    offer.otherSegments();
    this.content.find('.offer').remove();
    this.content.prepend(offer.el);
    this.offer = offer;
},
update: function(variants, lid) {
    var labels = local.offers[lid || this.id];
    if (variants && variants.length !== 0) {
        this.merge(variants);
        this.updateLabel(labels);
        var book = this.offer.el.find('.o-book');
        book.wrap('<div class="ob-placeholder"></div>');
        book.append('<div class="ob-shadow"></div>');
        book.after('<div class="ob-line"></div>');
        this.offer.el.find('.od-show').show().removeClass('od-show').addClass('od-scroll').click(function() {
            $w.smoothScrollTo(book.closest('.ob-placeholder').offset().top - 148);    
        });
        this.offer.el.find('.od-hide').remove();
    } else {
        this.clear(labels);
    }
},
updateLabel: function(labels) {
    var minprice = this.offer.variants[0].price;
    var maxprice = this.offer.variants.last().price;
    var sum = results.currencies['RUR'].absorb('<span class="rt-sum">' + minprice.separate() + '</span>');
    var price = minprice === maxprice ? sum : local.offers.price.from.absorb(sum);
    var title = labels[this.offer.variants.length === 1 ? 'one' : 'many'];
    this.control.html('{0} <span class="rt-price">{1}</span>'.absorb(title, price));
    this.control.removeClass('rt-disabled');
},
clear: function(labels) {
    this.control.addClass('rt-disabled');
    this.content.html('');
    this.control.html(labels.many);
    delete this.offer;
}
};

/* Featured offers */
results.cheap = new results.ComplexOffer('cheap');
results.nonstop = new results.ComplexOffer('nonstop');
results.optimal = new results.ComplexOffer('optimal');
