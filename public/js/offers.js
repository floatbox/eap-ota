$.extend(app.offers, {
options: {},
init: function() {
    
    this.container = $('#offers');
    this.loading = $('#offers-loading');
    this.results = $('#offers-results');
    this.empty = $('#offers-empty');
    this.update = {};

    // счётчик секунд на панели ожидания
    this.loading.timer = $('h4 i' , this.loading).timer();
    
    // Табы
    $('#offers-tabs').bind('select', function(e, v) {
        $('#offers-' + v).removeClass('g-none').siblings().addClass('g-none');
        app.offers.selectedTab = v;
    }).radio({
        toggleClosest: 'li'
    });

    // Подсветка
    $('#offers-list').delegate('.offer', 'mouseenter', function() {
        var self = $(this);
        $(this).data('timer', setTimeout(function() {
            self.addClass('hover');
        }, 400));
    }).delegate('.offer', 'mouseleave', function() {
        var el = $(this);
        clearTimeout(el.data('timer'));
        if (el.hasClass('collapsed')) el.removeClass('hover');
    });
    
    // Подробности
    $('#offers-list').delegate('.expand', 'click', function(event) {
        var variant = $(this).closest('.offer-variant');
        var offer = variant.parent();
        if (offer.hasClass('collapsed')) {
            offer.height(offer.height()).removeClass('collapsed').animate({
                height: variant.height()
            }, 400, function() {
                offer.height('auto').addClass('expanded hover');
            });
        }
    });
    $('#offers-list').delegate('.collapse', 'click', function(event) {
        $(this).closest('.offer').removeClass('expanded').addClass('collapsed');
    });
    
    // Сортировка
    $('#offers-list').delegate('.offers-sort a', 'click', function(event) {
        event.preventDefault();
        var self = app.offers, key = this.onclick();
        if (key != self.sortby) {
            var list = $('#offers-collection').css('opacity', 0.7);
            setTimeout(function() {
                list.hide();
                self.applySort(key);
                self.sortOffers();
                list.css('opacity', 1).show();
            }, 250);
        }
    });
    
    // Выбор времени вылета
    $('#offers-list').delegate('td.variants a', 'click', function(event) {
        event.preventDefault();
        var el = $(this), dtime = el.text().replace(':', '');
        var segment = parseInt(el.parent().attr('data-segment'), 10);
        var current = app.offers.variants[parseInt(el.closest('.offer-variant').attr('data-index'), 10)];
        var variants = current.offer.variants, departures = current.summary.departures.concat();
        departures[segment] = dtime;
        var query = departures.join(' '), match = undefined, half_match = undefined;
        for (var i = variants.length; i--;) {
            var variant = variants[i], dtimes = variant.summary.departures;
            if (variant.improper) continue;
            if (dtimes.join(' ') == query) {
                match = i;
            } else if (dtimes[segment] == dtime) {
                half_match = i;
            }
        }
        var result = match !== undefined ? match : half_match;
        if (result !== undefined) {
            var offer = el.closest('.offer-variant').addClass('g-none').closest('.offer');
            $('.offer-variant', offer).eq(parseInt(result, 10)).removeClass('g-none');
        }
    });
    
},
load: function(params, title) {
    var self = this;
    this.update = {
        title: title,
        loading: true
    };
    this.update.request = $.get("/pricer/", params, function(s) {
        if (self.update.aborted) return;
        var visible = self.loading.is(':visible');
        self.update.loading = false;
        if (typeof s == "string") {
            self.update.content = s;
            if (visible) self.processUpdate();
        } else {
            self.toggle('empty');
            alert(s && s.exception && s.exception.message);
        }
    });
},
show: function() {
    var self = this, u = this.update;
    app.search.toggle(false);
    if (u.title) {
        $('#offers-title h1').text(u.title);
    }
    if (u.loading) {
        this.toggle('loading');
    } else if (u.content != undefined) {
        this.toggle('loading');
        setTimeout(function() {
            self.processUpdate();
        }, 300);
    }
    if (u.action) {
        u.action();
        setTimeout(function() {
            self.toggle('results');
        }, 1200);
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
toggle: function(mode) {
    this.loading.toggleClass('g-none', mode != 'loading');
    this.results.toggleClass('g-none', mode != 'results');
    this.empty.toggleClass('g-none', mode != 'empty');
    // запускаем/останавливаем таймер счётчика
    this.loading.timer.trigger(mode == 'loading' ? 'start' : 'stop');
},
toggleCollection: function(mode) {
    var context = $('#offers-all');
    $('.offers-sort', context).toggleClass('g-none', !mode);
    $('.offers-improper', context).toggleClass('g-none', mode);
},
updateHash: function(hash) {
//    window.location.hash = encodeURIComponent(JSON.stringify(hash));
    window.location.hash = hash;
},
processUpdate: function() {
    var self = this, u = this.update;
    $('#offers-collection').remove();
    $('#offers-all').append(u.content || '');
    if ($('#offers-all .offer').length) {
        this.updateFilters();
        this.parseResults();
        this.toggleCollection(true);
        this.updateHash($('#offers-collection').attr('data-query_key'));
    } else {
        this.toggle('empty');
        this.variants = [];
        this.items = [];
    }
    this.update = {};
    if (this.items.length) {
        this.applySort('price');    
        if (this.maxLayovers) {
            this.filterOffers();
        } else {
            this.showAmount();
        }
        this.showDepartures();
        this.showRecommendations();
        $('#offers-tabs').trigger('set', this.selectedTab || 'best');
        setTimeout(function() {
            self.toggle('results');
        }, 1000);
    };
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
            vel.attr('data-index', variants.length);
            offer.variants.push(variant);
            variants.push(variant);
        });
        offer.multiple = offer.variants.length > 1;
        items.push(offer);
    });
    this.items = items;
    this.variants = variants;
},
showAmount: function(amount, total) {
    if (total === undefined) total = this.items.length;
    if (amount === undefined) amount = total;
    var str = amount + ' ' + app.utils.plural(amount, ['вариант', 'варианта', 'вариантов']);
    $('#offers-tab-all > a').text(amount == total ? ('Всего ' + str) : (str + ' из ' + total))
},
showVariant: function(el) {
    el.removeClass('g-none').siblings().addClass('g-none');
},
updateFilters: function() {
    this.filterable = false;
    var data = $.parseJSON($('#offers-collection').attr('data-filters'));
    $('#offers-filter .flight').each(function() {
        var items = $('p', this).trigger('update', data);
        var active = items.trigger('toggle').filter(':not(.g-none)');
        if (active.length > 0) {
            var city = $('.city', this);
            city.text(data[city.attr('data-key')]);
            $('.conjunction', this).toggle(active.length > 1);
            $(this).removeClass('g-none');
        } else {
            $(this).addClass('g-none');
        }
    });
    var items = $('#offers-filter td > p').each(function() {
        var el = $(this);
        el.trigger('update', data).trigger('toggle');
        el.next('.comma').toggle(!el.hasClass('g-none'));
    });
    items.filter(':not(.g-none)').last().next('.comma').hide();
    this.currentData = data;
    this.activeFilters = {};
    this.filterable = true;
},
resetFilters: function() {
    this.filterable = false;
    for (var key in this.activeFilters) {
        this.filters[key].trigger('reset');
        delete(this.activeFilters[key]);
    }
    this.filterable = true;
},
applyFilter: function(name, values) {
    var self = this, filters = this.activeFilters;
    if (name) {
        if (values.length) {
            filters[name] = values;
        } else {
            delete(filters[name]);
        }
    }
    var list = $('#offers-list').css('opacity', 0.7);
    setTimeout(function() {
        list.hide();
        self.filterOffers();
        self.sortOffers();
        self.showDepartures();
        self.showRecommendations();
        list.css('opacity', 1).show();
    }, 300);
},
filterOffers: function() {
    var filters = this.activeFilters, empty = true;
    var items = this.items, variants = this.variants;
    var ml = this.maxLayovers, total = items.length;
    for (var i = items.length; i--;) {
        var offer = items[i];
        if (offer.longer = ml && offer.summary.layovers > ml) total--;
        offer.improper = true;
    }
    for (var i = 0, im = variants.length; i < im; i++) {
        var v = variants[i], improper = false;
        if (v.offer.longer) {
            v.improper = true;
            v.el.addClass('improper');
            continue;
        }
        for (var key in filters) {
            empty = false;
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
        if (!offer.improper) amount++;
        offer.el.toggleClass('improper', offer.improper);
    }
    this.showAmount(amount, total);
    this.toggleCollection(amount > 0);
    $('#offers-reset-filters').toggleClass('g-none', empty);
},
applySort: function(key) {
    $('#offers-all .offers-sort a').each(function() {
        var el = $(this), hidden = (this.onclick() == key);
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
        var bestvariant = undefined, bestvalue = undefined;
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
        if (bestvariant) {
            if (bestvariant.el.hasClass('g-none')) this.showVariant(bestvariant.el);
            var svalue = commonvalue ? offer.summary[key] : bestvariant.summary[key];
            sitem.value = (svalue instanceof Array) ? svalue[0] : svalue;
            sitems.push(sitem);
        }
    }
    sitems.sort(function(a, b) {
        if (a.value > b.value) return 1;
        if (a.value < b.value) return -1;
        if (a.price > b.price) return 1;
        if (a.price < b.price) return -1;
        return 0;
    });

    var list = $('#offers-collection');
    for (var i = 0, lim = sitems.length; i < lim; i++) 
        list.append(sitems[i].offer.el);
},
showRecommendations: function() {
    var variants = this.variants, cheap, fast, optimal;
    for (var i = 0, im = variants.length; i < im; i++) {
        var v = variants[i];
        if (v.improper) continue;
        var d = v.summary.duration, p = v.offer.summary.price, pfd = p * (5 + v.summary.flights) + d * 2;
        if (!cheap || p < cheap.price || (p == cheap.price && d < cheap.duration)) cheap = {variant: v, duration: d, price: p};
        if (!fast || d < fast.duration || (d == fast.duration && p < fast.price)) fast = {variant: v, duration: d, price: p};
        if (!optimal || pfd < optimal.pfd) optimal = {variant: v, pfd: pfd};
    }
    var container = $('#offers-best').html('');
    if (!cheap && !fast && !optimal) {
        container.append($('#offers-collection').prev().clone());
        return;
    }
    if (cheap && fast && cheap.variant == fast.variant) {
        optimal = {variant: cheap.variant};
        cheap = undefined;
        fast = undefined;
    }
    if (cheap && optimal && cheap.variant == optimal.variant) {
        cheap = undefined;
    }
    if (fast && optimal && fast.variant == optimal.variant) {
        fast = undefined;
    }
    if (cheap) container.append(this.makeRecommendation(cheap, 'Самый выгодный вариант'));
    if (optimal) container.append(this.makeRecommendation(optimal, 'Оптимальный вариант — разумная цена и время в пути'));
    if (fast) container.append(this.makeRecommendation(fast, 'Самый быстрый вариант'));
},
makeRecommendation: function(obj, title) {
    var el = obj.variant.el, offer = el.parent().clone();
    this.showVariant(offer.children().eq(el.prevAll().length));
    return $('<div><h3 class="offers-title">' + title + '</h3></div>').append(offer);
},
getDepartures: function(offer) {
    var od = [], variants = offer.variants;
    for (var i = variants[0].summary.departures.length; i--;) {
        od[i] = {};
    }
    for (var i = variants.length; i--;) {
        var v = variants[i];
        if (v.improper) continue;
        var vd = v.summary.departures;
        for (var k = vd.length; k--;) {
            od[k][vd[k]] = true;
        }
    }
    var various = false;
    for (var i = od.length; i--;) {
        var d = [];
        for (var time in od[i]) d.push(time);
        if (od[i] = (d.length > 1) && d.sort()) various = true; 
    }
    return various && od;
},
showDepartures: function() {    
    var self = this, offers = this.items, dcities = [];
    for (var i = this.currentData.segments; i--;) {
        dcities[i] = this.currentData['dpt_city_' + i];
    }
    for (var i = 0, im = offers.length; i < im; i++) {
        var offer = offers[i];
        if (offer.improper || !offer.multiple) continue;
        var dtimes = this.getDepartures(offer);
        var variants = offer.variants;
        for (var k = variants.length; k--;) {
            var v = variants[k], empty = true;
            if (v.improper) continue;
            $('.variants', v.el).each(function(index) {
                var dt = dtimes[index];
                if (dt) {
                    var str = dcities[index] + '<br>в ' + self.joinDepartures(dt, v.summary.departures[index]);
                    $(this).html('<p class="b-pseudo" data-segment="' + index + '">Ещё по такой же цене можно улететь ' + str + '</p>');
                } else {
                    $(this).html('');
                }
            });
        }
    } 
},
joinDepartures: function(dtimes, current) {
    var parts = [];
    for (var i = 0, im = dtimes.length; i < im; i++) {
        var time = dtimes[i];
        if (time == current) continue;
        if (parts.length) parts.push(', ');
        parts.push('<a href="#"><u>' + time.substring(0,2) + ':' + time.substring(2,4) + '</u></a>');
    }
    var pl = parts.length;
    if (pl > 2) parts[pl - 2] = ' и в ';
    return pl ? parts.join('') : '';
}
});
