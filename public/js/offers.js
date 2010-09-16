$.extend(app.offers, {
options: {},
init: function() {
    
    this.container = $('#offers');
    this.loading = $('#offers-loading');
    this.results = $('#offers-results');
    this.update = {};

    // счётчик секунд на панели ожидания
    this.loading.timer = $('h4 i' , this.loading).timer();
    
    // Табы
    $('#offers-tabs').bind('select', function(e, v) {
        app.offers.showTab(v);
    }).radio({
        toggleClosest: 'li'
    });
    this.tab = 'best';

    // Подсветка
    $('#offers-list').delegate('.offer', 'mouseenter', function() {
        var self = $(this);
        $(this).data('timer', setTimeout(function() {
            self.addClass('hover');
        }, 400));
    }).delegate('.offer', 'mouseleave', function() {
        clearTimeout($(this).data('timer'));
        $(this).removeClass('hover');
    });
    
    // Подробности
    $('#offers-list').delegate('.expand', 'click', function(event) {
        var variant = $(this).closest('.offer-variant');
        var offer = variant.parent();
        if (offer.hasClass('collapsed')) {
            offer.height(offer.height()).removeClass('collapsed').animate({
                height: variant.height()
            }, 400, function() {
                offer.height('auto').addClass('expanded');
            });
        }
    });
    $('#offers-list').delegate('.collapse', 'click', function(event) {
        $(this).closest('.offer').removeClass('expanded').addClass('collapsed');
    });
    
    // Сортировка
    $('#offers-list').delegate('.offers-sort a', 'click', function(event) {
        event.preventDefault();
        var self = app.offers, key = $(this).attr('data-key');
        var list = $('#offers-collection').css('opacity', 0.7);
        setTimeout(function() {
            list.hide();
            self.applySort(key);
            self.sortOffers();
            list.css('opacity', 1).show();
        }, 250);
    });
    
    // Выбор времени вылета
    $('#offers-list').delegate('td.variants a', 'click', function(event) {
        event.preventDefault();
        var current = $(this).closest('.offer-variant');
        var departures = $.parseJSON(current.attr('data-summary')).departures;
        var sindex = parseInt($(this).attr('data-segment'), 10);
        var svalue = $(this).text().replace(':', '');
        departures[sindex] = svalue;
        var query = departures.join(' ');
        var match = null, half_match = null;
        current.siblings().each(function() {
            var variant = $(this);
            var vd = $.parseJSON(variant.attr('data-summary')).departures;
            if (vd.join(' ') == query) {
                match = variant;
                return false;
            } else if (vd[sindex] == svalue) {
                half_match = variant;
            }
        });
        var variant = match || half_match;
        if (variant) {
            if (variant.hasClass('improper')) {
                alert('Выбранный вариант вылета не соответствует текущим фильтрам');
                variant.removeClass('improper');
            }
            current.addClass('g-none');
            variant.removeClass('g-none');
        }
    });
    
},
load: function(data, title) {
    var self = this;
    this.update = {
        title: title,
        loading: true,
        content: ''
    };
    $.get("/pricer/", {
        search: data
    }, function(s) {
        var visible = self.loading.is(':visible');
        self.update.loading = false;
        self.loading.addClass('g-none');
        if (typeof s == "string") {
            self.update.content = s;
            if (visible) self.processUpdate();
        } else {
            alert(s && s.exception && s.exception.message);
        }
    });
},
show: function() {
    var self = this;
    app.search.toggle(false);
    $('#offers-title h1').text(this.update.title);
    if (!this.update.loading && this.update.content) {
        this.toggleLoading(true);
        setTimeout(function() {
            self.processUpdate();
        }, 300);
    } else {
        this.toggleLoading(this.update.loading);
    }
    this.container.removeClass('g-none');
    var w = $(window), wst = w.scrollTop();
    var offset = this.container.offset().top;
    if (offset - wst > w.height() / 2) {
        $({st: wst}).animate({
            st: offset - 112
        }, {
            duration: 500,
            step: function() {
                w.scrollTop(this.st);
            }
        });
    }
},
toggleLoading: function(mode) {
    this.loading.toggleClass('g-none', !mode);
    this.results.toggleClass('g-none', mode);

    // запускаем/останавливаем таймер счётчика
    this.loading.timer.trigger(mode ? 'start' : 'stop');
},
processUpdate: function() {
    $('#offers-collection').replaceWith(this.update.content);
    this.update.content = null;
    this.toggleLoading(false);
    this.updateFilters();
    this.parseResults();
    this.showAmount();
    this.showRecommendations();
    this.applySort('price')
    this.showTab('best');
},
showTab: function(v) {
    if (v) this.tab = v;
    var activeId = 'offers-' + this.tab;
    $('#offers-list').children().each(function() {
        $(this).toggleClass('g-none', $(this).attr('id') != activeId);
    });
},
showAmount: function(amount) {
    var total = this.items.length;
    if (amount == undefined) amount = total;
    var str = amount + ' ' + app.utils.plural(amount, ['вариант', 'варианта', 'вариантов']);
    $('#offers-tab-all > a').text(amount == total ? ('Всего ' + str) : (str + ' из ' + total))
},
updateFilters: function() {
    var collection = $('#offers-collection');
    var data = $.parseJSON(collection.attr('data-filters'));
    this.filterable = false;
    this.filters['airlines'].trigger('update', data);
    this.filters['planes'].trigger('update', data);
    for (var i = data.segments; i--;) {
        this.filters['arv_airport_' + i].trigger('update', data);
        this.filters['dpt_airport_' + i].trigger('update', data);
        this.filters['arv_time_' + i].trigger('update', data);
        this.filters['dpt_time_' + i].trigger('update', data);
    }
    this.activeFilters = {};
    this.filterable = true;
},
showVariant: function(el) {
    el.removeClass('g-none').siblings().addClass('g-none');
},
applyFilter: function(name, values) {
    var self = this, filters = this.activeFilters;
    if (values.length) {
        filters[name] = values;
    } else {
        delete(filters[name]);
    }
    var list = $('#offers-list').css('opacity', 0.7);
    setTimeout(function() {
        list.hide();
        self.filterOffers();
        self.showRecommendations();
        self.sortOffers();
        list.css('opacity', 1).show();
    }, 300);
},
filterOffers: function() {
    var filters = this.activeFilters;
    var items = this.items, variants = this.variants;
    for (var i = items.length; i--;) items[i].improper = true;
    for (var i = 0, im = variants.length; i < im; i++) {
        var v = variants[i], improper = false;
        for (var key in filters) {
            var fvalues = filters[key];
            var svalues = v.summary[key];
            if (!svalues) continue;
            var values = {};
            for (var k = fvalues.length; k--;) {
                values[fvalues[k]] = true;
            }
            if (svalues instanceof Array) {
                improper = true;
                for (var k = svalues.length; k--;) {
                    if (values[svalues[k]]) {
                        improper = false;
                        break;
                    }
                }
            } else {
                if (!values[svalues]) improper = true;
            }
            if (improper) break;
        }
        if (!improper) v.offer.improper = false;
        v.improper = improper;
        v.el.toggleClass('improper', improper);
    }
    var amount = 0;
    for (var i = items.length; i--;) {
        var offer = items[i];
        offer.el.toggleClass('improper', offer.improper);
        if (!offer.improper) amount++;
    }
    this.showAmount(amount);
},
applySort: function(key) {
    $('#offers-all .offers-sort a').each(function() {
        var el = $(this), hidden = (el.attr('data-key') == key);
        el.toggleClass('sortedby', hidden).toggleClass('b-pseudo', !hidden);
        if (hidden) $('#offers-sortedby').text(el.text());
    });
    this.sortby = key;
},
sortOffers: function() {
    var items = this.items, key = this.sortby, sitems = [];
    for (var i = 0, im = items.length; i < im; i++) {
        var offer = items[i], variants = offer.variants;
        if (offer.improper) continue;
        var sitem = {offer: offer, price: offer.summary.price};
        var commonvalue = key in offer.summary;
        var bestvariant, bestvalue;
        for (var k = 0, km = variants.length; k < km; k++) {
            var variant = variants[k];
            if (variant.improper) continue;
            if (!bestvariant && commonvalue) {
                bestvariant = variant;
                break;
            }
            var value = variant.summary[key];
            if (value instanceof Array) value = value[0];
            if (!bestvalue || value < bestvalue) {
                bestvariant = variant;
                bestvalue = value;
            }
        }
        if (bestvariant.el.hasClass('g-none')) this.showVariant(bestvariant.el);
        var svalue = commonvalue ? offer.summary[key] : bestvariant.summary[key];
        sitem.value = (svalue instanceof Array) ? svalue[0] : svalue;
        sitems.push(sitem);
    }
    sitems.sort(function(a, b) {
        if (a.value > b.value) return 1;
        if (a.value < b.value) return -1;
        if (a.price > b.price) return 1;
        if (a.price < b.price) return -1;
        return 0;
    });
    var list = $('#offers-collection');
    for (var i = 0, lim = sitems.length; i < lim; i++) {
        list.append(sitems[i].offer.el);
    }
},
parseResults: function() {
    var items = [], variants = [];
    $('#offers-collection .offer').each(function() {
        var el = $(this), offer = {
            el: el,
            summary: $.parseJSON(el.attr('data-summary')),
            variants: []
        };
        var children = el.children('.offer-variant').each(function() {
            var vel = $(this), variant = {
                el: vel,
                offer: offer,
                summary: $.parseJSON(vel.attr('data-summary'))
            };
            offer.variants.push(variant);
            variants.push(variant);
        });
        items.push(offer);
    });
    this.items = items;
    this.variants = variants;
},
showRecommendations: function() {
    var variants = this.variants, cheap, fast, optimal;
    for (var i = 0, im = variants.length; i < im; i++) {
        var v = variants[i];
        if (v.improper) continue;
        var d = v.summary.duration, p = v.offer.summary.price, s = v.summary.departures.length;
        if (!cheap || p < cheap.price || (p == cheap.price && d < cheap.duration)) cheap = {variant: v, duration: d, price: p};
        if (!fast || d < fast.duration || (d == fast.duration && p < fast.price)) fast = {variant: v, duration: d, price: p};
        if (!optimal || s < optimal.segments || (s == optimal.segments && p < optimal.price)) optimal = {variant: v, segments: s, price: p}
    }
    if (cheap.variant == optimal.variant) cheap = undefined;
    if (fast.variant == optimal.variant) fast = undefined;
    var container = $('#offers-best').html('');
    if (cheap) container.append(this.makeRecommendation(cheap, 'Самый выгодный вариант'));
    if (optimal) container.append(this.makeRecommendation(optimal, 'Оптимальный вариант — разумная цена и время в пути'));
    if (fast) container.append(this.makeRecommendation(fast, 'Самый быстрый вариант'));
},
makeRecommendation: function(obj, title) {
    var offer = obj.variant.el.parent().clone();
    return $('<div><h3 class="offers-title">' + title + '</h3></div>').append(offer);
}
});
