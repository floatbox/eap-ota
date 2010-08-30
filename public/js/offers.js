$.extend(app.offers, {
options: {},
init: function() {
    
    this.container = $('#offers');
    this.loading = $('#offers-loading');
    this.results = $('#offers-results');
    this.update = {};
    
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
    
    // Выбор времени вылета
    $('#offers-list').delegate('td.variants a', 'click', function(event) {
        event.preventDefault();
        var current = $(this).closest('.offer-variant')
        var departures = current.attr('data-departures').split(' ');
        var sindex = parseInt($(this).attr('data-segment'), 10);
        var svalue = $(this).text().replace(':', '');
        departures[sindex] = svalue;
        var query = departures.join(' ');
        var match = null, half_match = null;
        current.siblings().each(function() {
            var variant = $(this);
            var vd = variant.attr('data-departures');
            if (vd == query) {
                match = variant;
                return false;
            } else if (vd.split(' ')[sindex] == svalue) {
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
            if (visible) self.process();
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
            self.process();
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
},
process: function() {
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
applyFilter: function(name, values) {
    var filters = this.activeFilters;
    if (name) {
        if (values.length) {
            filters[name] = values;
        } else {
            delete(filters[name]);
        }
    }
    $('#offers-list .offer-variant').each(function() {
        var options = $.parseJSON($(this).attr('data-options'));
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
        if (denied) $(this).addClass('g-none');
        $(this).toggleClass('improper', denied);
    });
    $('#offers-list .offer').each(function() {
        var proper = $(this).children(':not(.improper)');
        $(this).toggleClass('improper', proper.length == 0);
        if (proper.length && proper.filter(':not(.g-none)').length == 0) proper.eq(0).removeClass('g-none');
    });
    this.showAmount($('#offers-all .offer:not(.improper)').length);
},
showAmount: function(amount) {
    var total = $('#offers-all').attr('data-amount');
    if (amount == undefined) amount = total;
    var str = amount + ' ' + app.utils.plural(amount, ['вариант', 'варианта', 'вариантов']);
    $('#offers-tab-all > a').text(amount == total ? ('Всего ' + str) : (str + ' из ' + total))
}
});
