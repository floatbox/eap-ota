var results = {
options: {},
init: function() {
    
    var that = this;

    this.el = $('#results');
    this.header = $('#results-header');
    this.title = $('#results-title');
    this.empty = $('#results-empty');
    this.loading = $('#results-loading');
    this.update = {};

    // счётчик секунд на панели ожидания
    this.stopwatch = this.loading.find('.timer');
    var swtimer, swstart, swupdate = function() {
        var current = new Date();
        that.stopwatch.text(((current - swstart) / 1000).toFixed(1));
    };
    this.stopwatch.bind('start', function() {
        swstart = new Date();
        swtimer = setInterval(swupdate, 100);
    });
    this.stopwatch.bind('stop', function() {
        clearInterval(swtimer);
    });
    
    // Табы
    $('#rtabs .link').click(function() {
        that.selectTab($(this).attr('data-tab'));
    });
    
    var offers = $('#offers');

    // Подсветка
    offers.delegate('.offer', 'mouseenter', function() {
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
    offers.delegate('.expand', 'click', function(event) {
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
    offers.delegate('.collapse', 'click', function(event) {
        var variant = $(this).closest('.offer-variant');
        var offer = variant.closest('.offer'), oh = offer.height();
        offer.height(oh).animate({
            height: oh - variant.find('.details').height()
        }, 400, function() {
            offer.removeClass('expanded').addClass('collapsed').height('auto');
        });
    });
    
    // Сортировка
    offers.delegate('.offers-sort a', 'click', function(event) {
        event.preventDefault();
        var key = this.onclick();
        if (key != results.sortby) {
            var list = $('#offers-pcollection').css('opacity', 0.7);
            setTimeout(function() {
                list.hide();
                results.applySort(key);
                results.sortOffers();
                list.css('opacity', 1).show();
            }, 250);
        }
    });
    
    // Выбор времени вылета
    offers.delegate('td.variants a', 'click', function(event) {
        event.preventDefault();
        var el = $(this), dtime = el.text().replace(':', '');
        if (el.closest('.offer').hasClass('active-booking')) {
            return; // Во время бронирования нельзя переключать варианты
        }
        var segment = parseInt(el.parent().attr('data-segment'), 10);
        var current = results.variants[parseInt(el.closest('.offer-variant').attr('data-index'), 10)];
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
    offers.delegate('.book .a-button', 'click', function(event) {
        event.preventDefault();
        var variant = $(this).closest('.offer-variant');
        app.booking.show(variant);
        app.booking.book(variant);
    });
    
    // Альянсы
    offers.delegate('.alliance', 'click', function(event) {
        var el = $(this);
        hint.show(event, 'В альянс ' + el.html() + ' входят авиакомпании: ' + el.attr('data-details') + '.');
    });

    // Соседние города
    var autoLoad = function() {
        results.load();
        results.show();
        search.onValid = undefined;
    };
    $('#offers-context').delegate('.city', 'click', function() {
        var el = $(this);
        var fields = el.closest('.cities').attr('data-fields').split(' ');
        for (var i = fields.length; i--;) {
            var fparts = fields[i].split('-');
            search.segments[parseInt(fparts[1], 10)][fparts[0]].trigger('set', el.text());
        }
        search.onValid = autoLoad;
    });
    this.empty.delegate('.city', 'click', function() {
        search.onValid = autoLoad;
        search.segments[0].to.trigger('set', $(this).text());
    });
},
selectTab: function(tab) {
    this.selectedTab = tab;
    this.filters.el.toggleClass('disabled', tab === 'matrix');
    $('#rtab-' + tab).addClass('selected').siblings().removeClass('selected');
    $('#offers-featured, #offers-all, #offers-matrix').addClass('latent');
    $('#offers-' + tab).removeClass('latent');
    pageurl.update('tab', tab);
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

    // Запросы для списка и календаря
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
    this.update.mrequest = $.ajax({
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
        fixedBlocks.update(true);
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
    $('#promo').addClass('latent');
    search.live.toggle(false);
    this.el.removeClass('latent');
    var w = $(window), offset = this.el.offset().top;
    if (fixed !== false && offset - w.scrollTop() > w.height() / 2) {
        $.animateScrollTop(offset - 112);
    }
},
hide: function() {
    this.el.addClass('latent');
    $('#promo').removeClass('latent');
    search.live.toggle(true);
},
toggle: function(mode) {
    this.el.toggleClass('ready', mode === 'ready');
    $('#results-filters, #rtabs, #offers').toggle(mode === 'ready');
    this.empty.toggleClass('latent', mode !== 'empty');
    this.loading.toggleClass('latent', mode !== 'loading');
    this.stopwatch.trigger(mode === 'loading' ? 'start' : 'stop');
    fixedBlocks.update();
},
toggleCollection: function(mode) {
    var context = $('#offers-all');
    $('.offers-sort', context).toggleClass('latent', !mode);
    $('.offers-improper', context).toggleClass('latent', mode);
},
processUpdate: function() {
    var self = this, u = this.update, queue = [];
    if (u.mcontent && u.mcontent.indexOf('offer-variant') !== -1) {
        queue.push(function() {
            $('#offers-mcollection').html(u.mcontent);
            self.matrix.process();
        });
    } else {
        $('#offers-mcollection').html('');
        self.matrix.process();
    }
    if (u.pcontent && u.pcontent.indexOf('offers-options') !== -1) {
        queue.push(function() {
            $('#offers-pcollection').html(u.pcontent);
        }, function() {
            var data = $.parseJSON($('#offers-options').attr('data-filters'));
            self.filters.update(data);
        }, function() {
            self.parseResults()
            self.applySort('price');
            self.showAmount();
        }, function() {
            self.showDepartures();
        }, function() {
            self.showRecommendations();
        }, function() {
            var nbc = $('#offers-pcollection .offers-nearby').remove();
            $('#offers-context .offers-nearby').html(nbc.html() || '');
            self.toggleCollection(true);
        });
    } else {
        $('#offers-pcollection').html('');
        $('#offers-context .offers-nearby').html('');
        this.variants = [];
        this.items = [];    
    }
    if (queue.length) {
        this.loading.find('h3').html('&nbsp;&nbsp;Еще чуть-чуть&hellip;');        
        var qstep = 0, processQueue = function() {
            queue[qstep++]();
            if (queue[qstep]) setTimeout(processQueue, 100);
        };
        queue.push(function() {
            self.toggle('ready');
            var imprecise = self.variants.length == 0;
            $('#results-filters, #rtabs').toggle(!imprecise);
            $('#offers-matrix .imprecise').toggleClass('latent', !imprecise)
            fixedBlocks.update();
            var b = app.booking, vid = b.el && b.el.attr('data-variant');
            if (vid && !b.variant) {
                var vparts = vid.split('-');
                b.variant = $('#offers-' + vparts[0] + ' .offer-variant[data-index="' + vparts[1] + '"]').eq(0);
                if (b.variant) {
                    b.offer = b.variant.closest('.offer');
                    self.showVariant(b.variant);
                    self.selectTab(vparts[0]);
                    b.el.appendTo(b.offer).removeClass('g-none');
                    b.show();
                    b.fasten(b.offer);
                    b.init();
                }
            } else {
                self.selectTab(imprecise ? 'matrix' : (self.selectedTab || pageurl.tab || 'featured'));
                pageurl.update('search', $(imprecise ? '#offers-matrix .matrix-origin' : '#offers-options').attr('data-query_key'));
                pageurl.title('авиабилеты ' + self.title.attr('data-title'));
            }
            delete(u.pcontent);
            delete(u.mcontent);
        });
        setTimeout(processQueue, 250);
    } else {
        if (u.pcontent && u.pcontent.indexOf('offers-nearby') !== -1) {
            var nearby = $('#offers-pcollection').html(u.pcontent).find('.offers-nearby .cities span.city');
            if (nearby.length) {
                var nearbyText = nearby.map(function() {
                    return $('<div/>').append(this).html();
                }).get().join(', ');
                self.empty.find('.rmtext p').html('Попробуйте упростить маршрут, поискать другие даты или соседние города: ' + nearbyText);
            } else {
                self.empty.find('.rmtext p').html('Попробуйте упростить маршрут или поискать другие даты');
            }
            $('#offers-pcollection').html('');
        }
        this.toggle('empty');
        fixedBlocks.update();
        pageurl.update('search', undefined);
        pageurl.title();
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
            if (offer.summary.alliance !== undefined) {
                variant.summary.alliance = offer.summary.alliance;
            }
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
    var str = amount.inflect('вариант', 'варианта', 'вариантов');
    $('#rtab-all .link').html(amount == total ? ('Всего ' + str) : (str + ' из ' + total));
},
showVariant: function(el) {
    el.removeClass('g-none').siblings().addClass('g-none');
},
applyFilters: function() {
    fixedBlocks.update();
    var self = this;
    var st = this.el.offset().top;
    if (st < $(window).scrollTop()) {
        $(window).scrollTop(st);
    }
    var list = $('#offers > .rcontent').addClass('translucent');
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
        list.removeClass('translucent');
    }];
    var qstep = 0, processQueue = function() {
        queue[qstep++]();
        if (queue[qstep]) setTimeout(processQueue, 30);
    };
    setTimeout(processQueue, 50);
},
filterOffers: function() {
    var filters = this.filters.selected, empty = true;
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
            if (svalues === undefined) {
                improper = true;
                continue;
            }
            var values = {};
            for (var k = fvalues.length; k--;) {
                values[fvalues[k]] = true;
            }
            if (svalues instanceof Array) {
                improper = true;
                for (var k = svalues.length; k--;) {
                    if (values[svalues[k]] !== undefined) {
                        improper = false;
                        break;
                    }
                }
            } else {
                if (values[svalues] === undefined) improper = true;
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
    this.filters.el.find('.rfreset').toggleClass('latent', empty);
    this.filters.el.find('.rftitle').toggleClass('latent', !empty);
    this.filtered = amount != total;
    this.showAmount(amount, total);
    this.toggleCollection(amount > 0);
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
    var container = $('#offers-featured').addClass('processing').html('');
    if (items.length == 0) {
        container.append($('#offers-pcollection').prev().clone()).removeClass('processing');
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
        if (cheap.n === fast.n || Math.abs(fast.p - cheap.p) < (fast.p + cheap.p) * 0.02) {
            optimal = {n: fast.n, p: fast.p};
            cheap = undefined;
            fast = undefined;
        } else if (Math.abs(fast.d - cheap.d) < 20) {
            optimal = {n: cheap.n, p: cheap.p};
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
            if (cheap.n === optimal.n || Math.abs(optimal.p - cheap.p) < (optimal.p + cheap.p) * 0.01) {
                cheap = undefined;
            }
            if (fast.n === optimal.n || Math.abs(fast.p - optimal.p) < (fast.p + optimal.p) * 0.01) {
                optimal = {n: fast.n, p: fast.p};
                fast = undefined;
            }
        }

    }
    var otitle = 'Лучшая цена';
    if (cheap && fast) {
        otitle = 'Оптимальный вариант — разумная цена и время в пути';
    } else if (cheap) {
        otitle = 'Быстрый и оптимальный вариант';
    }
    if (cheap) container.append(this.makeRecommendation(variants[cheap.n], 'Лучшая цена'));
    if (optimal) container.append(this.makeRecommendation(variants[optimal.n], otitle));
    if (fast) container.append(this.makeRecommendation(variants[fast.n], 'Долететь быстро'));
    if (!this.filtered) {
        var alamount = this.filters.items['carriers'].items.length.inflect('авиакомпании', 'авиакомпаний', 'авиакомпаний');
        var ftip = $('<div class="offers-title featured-tip"><strong>Не подошло?</strong> Воспользуйтесь уточнениями <span class="up">вверху&nbsp;&uarr;</span> или посмотрите <span class="link">все&nbsp;варианты</span> от&nbsp;' + alamount + '</div>');
        var that = this;
        ftip.find('.link').click(function() {
            that.selectTab('all');
            $.animateScrollTop(that.el.offset().top);
        });
        ftip.find('.up').click(function() {
            if (that.header.hasClass('fixed')) {
                $('#results-filters.hidden .rfshow').click();
            } else {
                $.animateScrollTop(that.el.offset().top);
            }
        });
        container.append(ftip);
        var rprice = cheap ? cheap.p : optimal.p;
        var mprice = parseInt($('#offers-matrix .offer-prices').attr('data-minprice'), 10);
        if (!isNaN(mprice) && mprice < rprice) {
            var mtip = $('<div class="offers-title featured-tip"><strong>Дорого?</strong> Посмотрите <span class="link">другие дни</span> — есть предложения от&nbsp;' + mprice.inflect('рубля', 'рублей', 'рублей') + '</div>');
            mtip.find('.link').click(function() {
                that.selectTab('matrix');
                $.animateScrollTop(that.el.offset().top);
            });
            container.append(mtip);
        }
    }
    container.removeClass('processing');
},
makeRecommendation: function(variant, title) {
    var el = variant.el, offer = el.parent().clone();
    this.showVariant(offer.children().eq(el.prevAll().length));
    if (title.search(/лучшая/i) !== -1) {
        var cost = offer.find('td.cost dl'), ctext = cost.find('dd');
        ctext.html(ctext.html() + '<span class="cost-tip">' + ($('#offers-options').attr('data-people') !== '1' ? ' за всех' : '') + ', включая налоги и сборы</span>');
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

// Фильтры
results.filters = {
init: function() {
    var that = this;
    this.items = {};
    this.selected = {};
    this.el = $('#results-filters');
    this.el.find('.filter').each(function() {
        var f = new controls.Filter($(this));
        f.template = ': $';
        f.el.bind('change', function(e, values) {
            var name = $(this).attr('data-name');
            if (values && values.length) {
                that.selected[name] = values;
            } else {
                delete(that.selected[name]);
            }            
            if (that.active) {
                results.applyFilters();
            }
        });
        that.items[$(this).attr('data-name')] = f;
    });
    this.el.find('.rfshow').click(function() {
        that.show();
    });
    this.el.find('.rfhide').click(function() {
        that.hide();
    });
    this.el.find('.rfreset').click(function() {
        that.reset();
        results.applyFilters();
    });
    $('#offers').delegate('.rfreset', 'click', function() {
        that.reset();
        results.applyFilters();
    });
    var lf = this.items['layovers'];
    lf.dropdown.removeClass('dropdown').addClass('vlist');
    lf.show = function() {};
    lf.hide = function() {};
},
show: function() {
    var height = this.el.height();
    var el = this.el.css({
        height: height,
        overflow: 'hidden'
    });
    el.removeClass('hidden').animate({
        height: el.find('.rfvisible').height()
    }, 150, function() {
        el.css({
            height: 'auto',
            overflow: ''
        });
    });
},
hide: function() {
    this.el.css({
        height: this.el.height(),
        overflow: 'hidden'
    }).animate({
        height: 30
    }, 150, function() {
        var el = $(this).addClass('hidden').css({
            height: 'auto',
            overflow: ''
        });
    });
},
reset: function() {
    this.active = false;
    for (var key in this.selected) {
        this.items[key].reset();
    }
    this.selected = {};
    this.active = true;
},
update: function(data) {
    this.active = false;
    var that = this;
    this.el.find('.rfreset').addClass('latent');
    this.el.find('.rftitle').removeClass('latent');
    this.el.find('.filter').each(function() {
        var name = $(this).attr('data-name');
        var f = that.items[name];
        f.fill(data[name]);
        f.el.toggleClass('latent', f.items.length < 2);
        var lid = f.el.attr('data-location');
        if (lid && data.locations[lid]) {
            f.el.find('.control').html((lid.charAt(0) == 'd' ? 'вылет ' : 'прилёт ') + data.locations[lid]);
        }
    });
    this.el.find('.filters').each(function() {
        $(this).closest('td').toggleClass('latent', $(this).find('.filter:not(.latent)').length === 0);
    });
    this.el.removeClass('hidden');
    this.data = data;
    this.selected = {};
    this.active = true;
}
};

// Матрица цен
results.matrix = {
init: function(table) {
    this.el = $('#offers-matrix');
    var table = this.el.find('.offer-prices');
    var frow = table.get(0).rows[0];
    var cells = table.find('td');
    var selected = table.find('td.selected'); 
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
            results.showVariant($('#mv-' + $(this).attr('data-vid')));
        }
    });
    cells.each(function() {
        var c = $(this);
        c.attr('data-col', c.prevAll().length);
    });    
},
process: function() {
    var table = this.el.find('.offer-prices').hide();
    var ordates, origin = this.el.find('.matrix-origin');
    var mtab = $('#rtab-matrix');    
    table.find('td').html('').removeClass('cheap active');
    if (origin.length) {
        this.el.find('.offer').removeClass('expanded').addClass('collapsed');
        table.find('.direction').html(origin.html());
        orDates = origin.attr('data-dates').split(' ');
        mtab.show();
    } else {
        mtab.hide();
        if (results.selectedTab == 'matrix' || pageurl.tab == 'matrix') {
            results.selectedTab = 'featured';
        }
        table.attr('data-minprice', '');
        return;
    }
    var rows = table.get(0).rows;
    var findex = {}, fdate = Date.parseAmadeus(orDates[0]).shiftDays(-3);
    for (var i = 0; i < 7; i++) {
        $(rows[0].cells[i + 1]).html(this.date(fdate));
        findex[fdate.toAmadeus()] = i + 1;
        fdate.shiftDays(1);
    }
    if (orDates[1]) {
        table.removeClass('owmatrix');
        var tindex = {};
        var tdate = Date.parseAmadeus(orDates[1]).shiftDays(-3);
        for (var i = 0; i < 7; i++) {
            $(rows[i + 1].cells[0]).html(this.date(tdate));
            tindex[tdate.toAmadeus()] = i + 1;
            tdate.shiftDays(1);
        }
    } else {
        table.addClass('owmatrix');
        var tindex = undefined;
    }
    var cheap = undefined;
    var variants = this.el.find('.offer-variant').each(function(i) {
        var el = $(this);
        var summary = $.parseJSON(el.attr('data-summary'));
        var cn = findex[summary.dates[0]];
        var rn = (tindex && summary.dates[1]) ? tindex[summary.dates[1]] : 4;
        var vid = summary.dates.join('-');
        var cell = $(rows[rn].cells[cn]).html(el.find('td.cost dt').html()).addClass('active').attr('data-vid', vid);
        el.attr('id', 'mv-' + vid).attr('data-index', i);
        if (!cheap || summary.price < cheap.price) {
            cheap = {price: summary.price, cells: cell};
        } else if (summary.price === cheap.price) {
            cheap.cells = cheap.cells.add(cell);
        }
    });
    if (cheap.cells.length / variants.length < 0.6) {
        cheap.cells.addClass('cheap');
    }
    var current = $(rows[4].cells[4]);
    if (current.hasClass('active')) {
        current.click();
    } else {
        cheap.cells.eq(0).click();
    }
    table.attr('data-minprice', cheap.price).show();
},
date: function(date) {
    var dm = date.getDate() + '&nbsp;' + constants.monthes.genitive[date.getMonth()];
    var wd = constants.weekdays[(date.getDay() || 7) - 1];
    return '<h6>' + dm + '</h6><p>' + wd + '</p>';
}
};
