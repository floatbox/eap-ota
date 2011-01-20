var offersList = {
options: {},
init: function() {
    this.title = $('#offers-title h1');
    this.container = $('#offers');
    this.loading = $('#offers-loading');
    this.results = $('#offers-results');
    this.content = $('#offers-content');
    this.empty = $('#offers-empty');
    this.update = {};

    // счётчик секунд на панели ожидания
    this.loading.timer = this.loading.find('.timer').timer();
    
    // Табы
    $('#offers-tabs').bind('select', function(e, v) {
        $('#offers-' + v).removeClass('g-none').siblings().addClass('g-none');
        offersList.selectedTab = v;
        pageurl.update('tab', v);
    }).radio({
        toggleClosest: 'li'
    });
    
    var list = $('#offers-list');

    // Подсветка
    list.delegate('.offer', 'mouseenter', function() {
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
    list.delegate('.expand', 'click', function(event) {
        var variant = $(this).closest('.offer-variant');
        var offer = variant.closest('.offer');
        if (offer.hasClass('collapsed')) {
            offer.height(offer.height()).removeClass('collapsed').animate({
                height: variant.height()
            }, 400, function() {
                offer.height('auto').addClass('expanded hover');
            });
        }
    });
    list.delegate('.collapse', 'click', function(event) {
        $(this).closest('.offer').removeClass('expanded').addClass('collapsed');
    });
    
    // Сортировка
    list.delegate('.offers-sort a', 'click', function(event) {
        event.preventDefault();
        var self = offersList, key = this.onclick();
        if (key != self.sortby) {
            var list = $('#offers-pcollection').css('opacity', 0.7);
            setTimeout(function() {
                list.hide();
                self.applySort(key);
                self.sortOffers();
                list.css('opacity', 1).show();
            }, 250);
        }
    });
    
    // Выбор времени вылета
    list.delegate('td.variants a', 'click', function(event) {
        event.preventDefault();
        var el = $(this), dtime = el.text().replace(':', '');
        if (el.closest('.offer').hasClass('active-booking')) {
            return; // Во время бронирования нельзя переключать варианты
        }
        var segment = parseInt(el.parent().attr('data-segment'), 10);
        var current = offersList.variants[parseInt(el.closest('.offer-variant').attr('data-index'), 10)];
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
    
    // Бронирование
    list.delegate('.book .a-button', 'click', function(event) {
        event.preventDefault();
        var variant = $(this).closest('.offer-variant');
        app.booking.show(variant);
        app.booking.book(variant);
    });
    
    // Соседние города
    this.content.delegate('.offers-context .city', 'click', function() {
        var el = $(this);
        var fields = el.closest('.cities').attr('data-fields').split(' ');
        for (var i = fields.length; i--;) {
            var fparts = fields[i].split('-');
            search.segments[parseInt(fparts[1], 10)][fparts[0]].trigger('set', el.text());
        }
        $.animateScrollTop(0);
    });
    
    // Матрица цен
    this.initMatrix();
    
},
load: function() {
    var self = this;
    if (!this.nextUpdate) {
        return;
    }
    if (this.update && this.update.loading) {
        this.abort();
    }
    this.update = {
        title: this.nextUpdate.title,
        loading: true
    };
    var params = $.extend({}, this.nextUpdate.params);
    this.nextUpdate = undefined;
    this.update.prequest = $.ajax({
        url: '/pricer/',
        data: params,
        success: function(s, status, request) {
            if (self.update.prequest != request) return;
            self.setUpdate('pcontent', s);
        },
        error: function(request) {
            if (self.update.prequest != request) return;
            self.setUpdate('pcontent', '');
        },
        timeout: 150000
    });

    // Запрос матрицы с задержкой, чтобы не слать лишние запросы при автоматическом поиске
    this.mrtimer = setTimeout(function() {
        self.update.mrequest =  $.ajax({
            url: '/calendar/',
            data: params,
            success: function(s, status, request) {
                if (self.update.mrequest != request) return;
                self.setUpdate('mcontent', s);
            },
            error: function(request) {
                if (self.update.mrequest != request) return;
                self.setUpdate('mcontent', '');
            },
            timeout: 60000
        });
    }, params.restore_results ? 1000 : 10000);
    
    // Ничего не найдено, если не сработали таймауты запросов
    clearTimeout(this.resetTimer);
    this.resetTimer = setTimeout(function() {
        self.setUpdate('pcontent', '');
        self.setUpdate('mcontent', '');
    }, 160000);
    
},
setUpdate: function(type, s) {
    this.update[type] = typeof s == 'string' ? s : '';
    var pc = this.update.pcontent;
    var mc = this.update.mcontent;
    if (pc !== undefined && mc !== undefined) {
        clearTimeout(this.resetTimer);
        this.update.loading = false;
        if (this.loading.is(':visible')) {
            pc ? this.processUpdate() : this.toggle('empty');
        }
    }
},
abort: function() {
    clearTimeout(this.mrtimer);
    if (this.update) {
        var pr = this.update.prequest;
        var mr = this.update.mrequest;
        if (pr && pr.abort) pr.abort();
        if (mr && mr.abort) mr.abort();
        delete(this.update.pr);
        delete(this.update.mr);
    }
},
show: function(fixed) {
    var self = this, u = this.update;
    search.toggle(false);
    search.submit.addClass('current');
    if (u.title) {
        this.title.html(u.title);
        var locations = this.title.find('.locations');
        var ls = locations.map(function() {
            return locations.length > 1 ? $(this).attr('data-short') : $(this).text();
        }).get().join(', ');
        var ds = this.title.find('.date').map(function() {
            return $(this).attr('data-date');
        }).get().join(locations.length > 1 ? ', ' : '—');
        this.title.attr('data-title', ls.replace(/— (.*?),(?= \1 —)/g, '—') + ' (' + ds + ')');
    }
    if (u.loading) {
        this.toggle('loading');
        pageurl.title();
    } else if (u.pcontent) {
        this.toggle('loading');
        setTimeout(function() {
            self.processUpdate();
        }, 300);
    }
    this.loading.find('h3').html('Ищем для вас лучшие предложения');
    this.container.removeClass('g-none');
    var w = $(window), offset = this.container.offset().top;
    if (fixed !== false && offset - w.scrollTop() > w.height() / 2) {
        $.animateScrollTop(offset - 112, function() {
            var promo = $('#promo');
            if (promo.is(':visible')) {
                var st = w.scrollTop() - promo.outerHeight();
                promo.hide();
                w.scrollTop(st);
            }        
        });
    } else {
        $('#promo').slideUp(200);
    }
},
hide: function() {
    this.container.addClass('g-none');
},
toggle: function(mode) {
    this.container.toggleClass('with-results', mode == 'results');
    this.loading.toggleClass('g-none', mode != 'loading');
    this.results.toggleClass('g-none', mode != 'results');
    this.empty.toggleClass('g-none', mode != 'empty');
    this.loading.timer.trigger(mode == 'loading' ? 'start' : 'stop');
},
toggleCollection: function(mode) {
    var context = $('#offers-all');
    $('.offers-sort', context).toggleClass('g-none', !mode);
    $('.offers-improper', context).toggleClass('g-none', mode);
},
processUpdate: function() {
    var self = this, u = this.update;
    if (u.pcontent && u.pcontent.indexOf('offers-options') > 0) {
        this.loading.find('h3').html('&nbsp;&nbsp;Еще чуть-чуть&hellip;');
        var queue = [function() {
            $('#offers-pcollection').html(u.pcontent);
            $('#offers-mcollection').html(u.mcontent);
        }, function() {
            self.updateFilters();
        }, function() {
            self.parseResults()
            self.applySort('price');
            self.showAmount();
        }, function() {
            self.showDepartures();
        }, function() {
            self.processMatrix();
        }, function() {
            self.showRecommendations();
        }, function() {
            var b = app.booking, vid = b.el && b.el.attr('data-variant');
            if (vid && !b.variant) {
                var vparts = vid.split('-');
                b.variant = $('#offers-' + vparts[0] + ' .offer-variant[data-index="' + vparts[1] + '"]').eq(0);
                b.offer = b.variant.closest('.offer');
                self.showVariant(b.variant);
                b.el.appendTo(b.offer).addClass('restored');
                $('#offers-tabs').trigger('set', vparts[0]);
            } else {
                $('#offers-tabs').trigger('set', self.selectedTab || pageurl.tab || 'featured');
                pageurl.update('search', $('#offers-options').attr('data-query_key'));
                pageurl.title('авиабилеты ' + self.title.attr('data-title'));
            }
        }, function() {
            self.content.children('.offers-context').remove();
            self.content.find('.offers-context').prependTo(self.content).removeClass('g-none');
            self.toggleCollection(true);
            self.toggle('results');
            var b = app.booking;
            if (b.el && b.el.hasClass('restored')) {
                b.show();
                b.el.removeClass('restored g-none');
                b.fasten(b.offer);
                b.init();
            }
            delete(u.pcontent);
            delete(u.mcontent);
        }];
        var qstep = 0, processQueue = function() {
            queue[qstep++]();
            if (queue[qstep]) setTimeout(processQueue, 150);
        };
        setTimeout(processQueue, 500);
    } else {
        this.toggle('empty');
        $('#offers-pcollection').html('');
        $('#offers-mcollection').html('');
        pageurl.update('search', undefined);
        pageurl.title();
        this.variants = [];
        this.items = [];
        delete(u.pcontent);
        delete(u.mcontent);
    }
},
parseResults: function() {
    var items = [], variants = [];
    $('#offers-pcollection .offer').each(function() {
        var el = $(this), offer = {
            el: el,
            summary: $.parseJSON(el.attr('data-summary')),
            variants: []
        };
        el.children('.offer-variant').each(function() {
            var vel = $(this), variant = {
                el: vel,
                offer: offer,
                summary: $.parseJSON(vel.attr('data-summary'))
            };
            vel.attr('data-index', variants.length);
            offer.variants.push(variant);
            variants.push(variant);
        }).eq(0).removeClass('g-none');
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
    $('#offers-tab-all > a').text(amount == total ? ('Всего ' + str) : (str + ' из ' + total));
},
showVariant: function(el) {
    el.removeClass('g-none').siblings().addClass('g-none');
},
updateFilters: function() {
    this.filterable = false;
    var self = this;
    var data = $.parseJSON($('#offers-options').attr('data-filters'));
    $('#offers-reset-filters').addClass('g-none');
    $('#offers-filter .flight').each(function() {
        var active = $('.filter', this).each(function() {
            var name = $(this).attr('data-name');
            var filter = self.filters[name];
            filter.fill(data[name]);
            filter.el.toggleClass('g-none', filter.items.length < 2);
        }).filter(':not(.g-none)');
        if (active.length > 0) {
            var city = $('.city', this);
            city.text((data.locations || [])[city.attr('data-location')] || '');
            $('.conjunction', this).toggle(active.length > 1);
            $(this).removeClass('g-none');
        } else {
            $(this).addClass('g-none');
        }
    });
    var items = $('#offers-filter .filters > .filter').each(function() {
        var name = $(this).attr('data-name');
        var filter = self.filters[name];
        filter.fill(data[name]);
        filter.el.toggleClass('g-none', filter.items.length < 2);
        $(this).next('.comma').toggle(!filter.el.hasClass('g-none'));
    });
    items.filter(':not(.g-none)').last().next('.comma').hide();
    this.currentData = data;
    this.activeFilters = {};
    this.filterable = true;
},
resetFilters: function() {
    this.filterable = false;
    for (var key in this.activeFilters) {
        this.filters[key].reset();
        delete(this.activeFilters[key]);
    }
    this.filterable = true;
},
applyFilter: function(name, values) {
    var self = this, filters = this.activeFilters;
    if (name) {
        if (values && values.length) {
            filters[name] = values;
        } else {
            delete(filters[name]);
        }
    }
    var list = $('#offers-list').css('opacity', 0.7);
    var queue = [function() {
        list.hide();
        self.filterOffers();
        list.show();
    }, function() {
        list.hide();
        self.sortOffers();
        list.show();        
    }, function() {
        list.hide();
        self.showDepartures();
        list.show();
    }, function() {
        self.showRecommendations();
        list.css('opacity', 1);
    }];
    var qstep = 0, processQueue = function() {
        queue[qstep++]();
        if (queue[qstep]) setTimeout(processQueue, 50);
    };
    setTimeout(processQueue, 200);
},
filterOffers: function() {
    var filters = this.activeFilters, empty = true;
    var items = this.items, variants = this.variants;
    var total = items.length;
    for (var i = items.length; i--;) {
        items[i].improper = true;
    }
    for (var i = 0, im = variants.length; i < im; i++) {
        var v = variants[i], improper = false;
        for (var key in filters) {
            empty = false;
            var fvalues = filters[key];
            var svalues = v.summary[key];
            if (svalues === undefined) continue;
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
    this.filtered = amount != total;
    this.showAmount(amount, total);
    this.toggleCollection(amount > 0);
    $('#offers-reset-filters').toggleClass('g-none', empty);
},
applySort: function(key) {
    $('#offers-all .offers-sort a').each(function() {
        var hidden = (this.onclick() == key);
        var el = $(this).toggleClass('sortedby', hidden);
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
    var list = $('#offers-pcollection');
    for (var i = 0, lim = sitems.length; i < lim; i++) {
        list.append(sitems[i].offer.el);
    }
},
showRecommendations: function() {
    var items = [], variants = this.variants;
    var cheap = undefined, fast = undefined, optimal = undefined;
    for (var i = 0, im = variants.length; i < im; i++) {
        var v = variants[i];
        if (!v.improper) {
            items.push({n: i, p: v.offer.summary.price, d: v.summary.duration});
        }
    }
    var container = $('#offers-featured').hide().html('');
    if (items.length == 0) {
        container.append($('#offers-pcollection').prev().clone()).show();
        return;
    } else if (items.length == 1) {
        optimal = items[0];
    } else {

        // Выгодный вариант с отсеиванием слишком долгих
        cheap = items[0];
        var item, ratio, defitem = items[0], minratio = 0.8;
        for (var i = 1, im = items.length; i < im; i++) {
            item = items[i];
            if (item.p / defitem.p > 1.05) break;
            if ((ratio = item.p / defitem.p * item.d / defitem.d) < minratio) {
                minratio = ratio;
                cheap = item;
            }
        }
        
        // Быстрый вариант с отсеиванием слишком дорогих
        items = items.sort(function(a, b) {
            return (a.d - b.d) || (a.p - b.p);
        });
        fast = items[0];
        var item, ratio, defitem = items[0], minratio = 0.7;
        for (var i = 1, im = items.length; i < im; i++) {
            item = items[i];
            if (item.d / defitem.d > 1.2) break;
            if ((ratio = item.p / defitem.p * item.d / defitem.d) < minratio) {
                minratio = ratio;
                fast = item;
            }
        }
        
        // Оптимальный вариант
        if (cheap.n === fast.n || Math.abs(fast.p - cheap.p) < (cheap.p + fast.p) * 0.02) {
            optimal = {n: fast.n, p: fast.p};
            cheap = undefined;
            fast = undefined;
        } else {
            optimal = cheap;
            var item, ratio, maxratio = 0;
            var dd = cheap.d - fast.d, pp = fast.p - cheap.p;
            for (var i = 1, im = items.length; i < im; i++) {
                item = items[i];
                if (item.d < fast.d || item.d > cheap.d || item.p < cheap.p || item.p > fast.p) continue;
                if ((ratio = (cheap.d - item.d) / dd - (item.p - cheap.p) / pp) > maxratio) {
                    maxratio = ratio;
                    optimal = items[i];
                }
            }
            if (cheap.n === optimal.n) {
                cheap = undefined;
            }
            if (fast.n === optimal.n) {
                fast = undefined;
            }
        }

    }
    var otitle = 'Самый выгодный и быстрый вариант';
    if (cheap && fast) {
        otitle = 'Оптимальный вариант — разумная цена и время в пути';
    } else if (cheap) {
        otitle = 'Быстрый и оптимальный вариант';
    } else if (fast) {
        otitle = 'Самый выгодный и оптимальный вариант';
    }
    if (cheap) container.append(this.makeRecommendation(variants[cheap.n], 'Самый выгодный вариант'));
    if (optimal) container.append(this.makeRecommendation(variants[optimal.n], otitle));
    if (fast) container.append(this.makeRecommendation(variants[fast.n], 'Быстрый вариант'));
    if (!this.filtered) {
        var aln = this.filters['carriers'].items.length, alamount = aln + '&nbsp;' + app.utils.plural(aln, ['авиакомпании', 'авиакомпаний', 'авиакомпаний']);
        var ftip = $('<div class="offers-title featured-tip"><strong>Не подошло?</strong> Воспользуйтесь уточнениями <span class="up">вверху&nbsp;&uarr;</span> или посмотрите <span class="link">все&nbsp;варианты</span> от&nbsp;' + alamount + '</div>');
        var that = this;
        ftip.find('.link').click(function() {
            $('#offers-tabs').trigger('set', 'all');
            $.animateScrollTop(that.container.offset().top - 42);
        });
        ftip.find('.up').click(function() {
            $.animateScrollTop(that.container.offset().top - 42);
        });
        container.append(ftip);
        var rprice = cheap ? cheap.p : optimal.p;
        var mprice = parseInt($('#offers-matrix .offer-prices').attr('data-minprice'), 10);
        if (mprice < rprice) {
            var mtip = $('<div class="offers-title featured-tip"><strong>Дорого?</strong> Посмотрите <span class="link">другие дни</span> — есть предложения от&nbsp;' + mprice + '&nbsp;' + app.utils.plural(mprice, ['рубля', 'рублей', 'рублей']) + '</div>');
            mtip.find('.link').click(function() {
                $('#offers-tabs').trigger('set', 'matrix');
                $.animateScrollTop(that.container.offset().top - 42);
            });
            container.append(mtip);
        }
    }
    container.show();
},
makeRecommendation: function(variant, title) {
    var el = variant.el, offer = el.parent().clone();
    this.showVariant(offer.children().eq(el.prevAll().length));
    if (title.search(/выгодный/i) != -1) {
        var cost = offer.find('td.cost dl'), ctext = cost.find('dd');
        ctext.html(ctext.html() + '<span class="cost-tip"> за всех, включая налоги и сборы</span>');
        cost.prepend('<dd>Всего </dd>');
    }
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
    var self = this, offers = this.items;
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
                    var str = offer.summary['dpt_location_' + index] + '<br>в ' + self.joinDepartures(dt, v.summary.departures[index]);
                    $(this).html('<p data-segment="' + index + '">Ещё по такой же цене можно улететь ' + str + '</p>');
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
        parts.push('<a href="#">' + time.substring(0,2) + ':' + time.substring(2,4) + '</a>');
    }
    var pl = parts.length;
    if (pl > 2) parts[pl - 2] = ' и в ';
    return pl ? parts.join('') : '';
}
};

// Матрица цен
$.extend(offersList, {
initMatrix: function(table) {
    var table = $('#offers-matrix .offer-prices');
    var cells = $('td', table);
    var frow = table.get(0).rows[0];
    var selected = $('td.selected', table); 
    var htimer, highlight = function(td) {
        hlcurrent.removeClass('current');
        hlcurrent = $(frow.cells[parseInt(td.attr('data-col'), 10)]).add(td.parent()).addClass('current');
    };
    var self = this;
    var hlcurrent = $('.current', table);
    $(table).delegate('td', 'mouseenter', function() {
        clearTimeout(htimer);
        highlight($(this));
    }).delegate('td', 'mouseleave', function() {
        htimer = setTimeout(function() {
            highlight(selected);
        }, 50);
    }).delegate('td.active', 'click', function() {
        if (!$(this).closest('.offer').hasClass('active-booking')) {
            selected.removeClass('selected').addClass('active');
            selected = $(this).addClass('selected').removeClass('active');
            self.showVariant($('#mv-' + $(this).attr('data-vid')));
        }
    });
    cells.each(function() {
        var c = $(this);
        c.attr('data-col', c.prevAll().length);
    });    
},
processMatrix: function() {
    var context = $('#offers-matrix');
    var table = context.find('.offer-prices').hide();
    table.find('td').html('').removeClass('active');
    var ordates, origin = context.find('.matrix-origin');
    var mtab = $('#offers-tab-matrix');    
    if (origin.length) {
        context.find('.offer').removeClass('expanded').addClass('collapsed');
        orDates = origin.attr('data-dates').split(' ');
        mtab.show();
    } else {
        mtab.hide();
        if (this.selectedTab == 'matrix' || pageurl.tab == 'matrix') {
            this.selectedTab = 'featured';
        }
        return;
    }
    var rows = table.get(0).rows;
    var findex = {}, fdate = Date.parseAmadeus(orDates[0]).shiftDays(-3);
    for (var i = 0; i < 7; i++) {
        $(rows[0].cells[i + 1]).html(this.matrixDate(fdate));
        findex[fdate.toAmadeus()] = i + 1;
        fdate.shiftDays(1);
    }
    if (orDates[1]) {
        table.removeClass('owmatrix');
        var tindex = {};
        var tdate = Date.parseAmadeus(orDates[1]).shiftDays(-3);
        for (var i = 0; i < 7; i++) {
            $(rows[i + 1].cells[0]).html(this.matrixDate(tdate));
            tindex[tdate.toAmadeus()] = i + 1;
            tdate.shiftDays(1);
        }
    } else {
        table.addClass('owmatrix');
        var tindex = undefined;
    }
    var cheap = undefined;
    var variants = context.find('.offer-variant').each(function(i) {
        var el = $(this);
        var summary = $.parseJSON(el.attr('data-summary'));
        var cn = findex[summary.dates[0]];
        var rn = (tindex && summary.dates[1]) ? tindex[summary.dates[1]] : 4;
        var vid = summary.dates.join('-');
        var cell = $(rows[rn].cells[cn]).html(el.find('td.cost dt').html()).addClass('active').attr('data-vid', vid);
        el.attr('id', 'mv-' + vid).attr('data-index', i);
        if (cheap && summary.price == cheap.price) {
            cheap.cells = cheap.cells.add(cell);
        } else if (!cheap || summary.price < cheap.price) {
            cheap = {price: summary.price, cells: cell};
        }
    });
    if (cheap.length / variants.length < 0.6) {
        cheap.cells.addClass('cheap');
    }
    $(rows[4].cells[4]).click();
    table.attr('data-minprice', cheap.price).show();
},
matrixDate: function(date) {
    var dm = date.getDate() + '&nbsp;' + app.constant.MNg[date.getMonth()];
    var wd = app.constant.DN[(date.getDay() || 7) - 1];
    return '<h6>' + dm + '</h6><p>' + wd + '</p>';
}
});
