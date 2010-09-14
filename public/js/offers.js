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
    $('#offers-list').delegate('.offer', 'mouseover', function() {
        $(this).addClass('hover');
    }).delegate('.offer', 'mouseout', function() {
        $(this).removeClass('hover');
    });
    
    // Подробности
    $('#offers-list').delegate('.expand', 'click', function(event) {
        var variant = $(this).closest('.offer-variant');
        var offer = variant.parent();
        if (offer.hasClass('collapsed')) {
            offer.height(offer.height()).removeClass('collapsed').animate({
                height: variant.height()
            }, 500, function() {
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
        app.offers.sortBy($(this).attr('data-key'));
    });
    
    // Выбор времени вылета
    $('#offers-list').delegate('td.variants a', 'click', function(event) {
        event.preventDefault();
        var getSummary = app.offers.getSummary;
        var current = $(this).closest('.offer-variant')
        var departures = $.makeArray(getSummary(current).departures);
        var sindex = parseInt($(this).attr('data-segment'), 10);
        var svalue = $(this).text().replace(':', '');
        departures[sindex] = svalue;
        var query = departures.join(' ');
        var match = null, half_match = null;
        current.siblings().each(function() {
            var variant = $(this);
            var vd = getSummary(variant).departures;
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
    $('#offers-list').html(this.update.content);
    this.showAmount();
    this.showTab();
    this.toggleLoading(false);
    this.update.content = null;
    this.updateFilters();
},
showTab: function(v) {
    if (v) this.tab = v;
    var activeId = 'offers-' + this.tab;
    $('#offers-list').children().each(function() {
        $(this).toggleClass('g-none', $(this).attr('id') != activeId);
    });
},
showAmount: function(amount) {
    var total = $('#offers-all').attr('data-amount');
    if (amount == undefined) amount = total;
    var str = amount + ' ' + app.utils.plural(amount, ['вариант', 'варианта', 'вариантов']);
    $('#offers-tab-all > a').text(amount == total ? ('Всего ' + str) : (str + ' из ' + total))
},
updateFilters: function() {
    var data = $.parseJSON(this.filtersData);
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
getSummary: function(el) {
    var summary = el.data('summary');
    if (!summary) {
        summary = $.parseJSON(el.attr('data-summary'));
        el.data('summary', summary);
    }
    return summary;
},
showVariant: function(el) {
    $(el).removeClass('g-none').siblings().addClass('g-none');
},
applyFilter: function(name, values) {
    var self = this, filters = this.activeFilters;
    if (values.length) {
        filters[name] = values;
    } else {
        delete(filters[name]);
    }
    var fast, cheap, optimal;
    var list = $('#offers-all').hide();
    $('.offer-variant', list).each(function() {
        var options = self.getSummary($(this));
        var denied = false;
        for (var key in filters) {
            var fvalues = filters[key];
            var ovalues = options[key];
            if (!ovalues) continue;
            var values = {};
            for (var i = fvalues.length; i--;) {
                values[fvalues[i]] = true;
            }
            if (ovalues instanceof Array) {
                denied = true;
                for (var i = ovalues.length; i--;) {
                    if (values[ovalues[i]]) {
                        denied = false;
                        break;
                    }
                }
            } else {
                if (!values[ovalues]) denied = true;
            }
            if (denied) break;
        }
        if (denied) {
            $(this).addClass('g-none');
        } else {
            if (!fast || options.duration < fast.duration) fast = {el: $(this), duration: options.duration};
            if (!cheap || options.price < cheap.price) cheap = {el: $(this), price: options.price};
        }
        $(this).toggleClass('improper', denied);
    });
    var proper_amount = 0;
    $('.offer', list).each(function() {
        var proper = $(this).children('.offer-variant:not(.improper)');
        $(this).toggleClass('improper', proper.length == 0);
        if (proper.length) {
            self.showVariant(proper.eq(0));
            proper_amount++;
        }
    });
    list.show();
    this.showAmount(proper_amount);
},
sortBy: function(key) {
    var self = this, items = [], list = $('#offers-all');
    list.hide().children('.offer').each(function() {
        var offer = $(this), summary = self.getSummary(offer);
        var ovalue = summary[key], item = {offer: offer, price: summary.price};
        if (ovalue) {
            item.value = ovalue;
        } else if (offer.hasClass('multiple')) {
            var variant;
            offer.children('.offer-variant').each(function() {
                var value = self.getSummary($(this))[key];
                if (value instanceof Array) value = value[0];
                if (item.value === undefined || value < item.value) {
                    item.value = value;
                    variant = $(this);
                }
            });
            self.showVariant(variant);
        } else {
            var value = self.getSummary(offer.children().first())[key];
            if (value instanceof Array) value = value[0];
            item.value = value;
        }
        items.push(item);
    });
    items.sort(function(a, b) {
        if (a.value > b.value) return 1;
        if (a.value < b.value) return -1;
        if (a.price > b.price) return 1;
        if (a.price < b.price) return -1;
        return 0;
    });
    for (var i = 0, lim = items.length; i < lim; i++) {
        list.append(items[i].offer);
    }
    var context = $('.offers-sort', list);
    $('.b-pseudo', context).each(function() {
        var hidden = ($(this).attr('data-key') == key);
        $(this).toggleClass('g-none', hidden).next('.spacer').text(', ').toggleClass('g-none', hidden);
        if (hidden) $('#offers-sortedby').text($(this).text());
    });
    $('.offers-sort .spacer:not(.g-none)', list).last().text(' или ');
    list.show();
}
});
