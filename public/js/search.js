var search = {
init: function() {
    var self = this;
    
    // Откуда
    this.from = $('#search-from').autocomplete({
        cls: 'autocomplete-gray',
        url: '/complete.json',
        root: 'data',
        height: 374,
        loader: new app.Loader({
            parent: $('#search-from-loader')
        }),
        params: {
            input: 'from',
            limit: 30
        }
    }).focus(function() {
        self.from.reset.fadeOut(200);
    }).change(function() {
        self.update(this);
    });
    this.from.reset = $('#search-from-reset').click(function(e) {
        self.from.focus().trigger('set', '');
    });
    var fdata = this.from.get(0).onclick();
    if (fdata && fdata.iata) {
        self.from.trigger('iata', fdata.iata);
    }    
    
    // Куда
    this.to = $('#search-to').autocomplete({
        cls: 'autocomplete',
        url: '/complete.json',
        root: 'data',
        width: 340,
        height: 378,
        loader: new app.Loader({
            parent: $('#search-to-loader')
        }),
        params: {
            input: 'to',
            limit: 30
        }
    }).change(function() {
        var el = $(this), v = el.val();
        if (v != el.data('pval')) self.update(this);
        el.data('pval', v);
    });
    
    // Календарь
    this.calendar = new app.Calendar("#search-calendar");
    
    // Селекты
    $('#search-define .filter').each(function() {
        self[$(this).attr('data-name')] = new controls.Filter(this, {radio: true, preserve: true});
    });
    this.persons.el.bind('change', function(e, values) {
        self.update();
    });
    this.cabin.el.bind('change', function(e, values) {
        self.update();
    });
    this.changes.el.bind('change', function(e, values) {
        if (app.offers.results.is(':visible')) {
            self.toggle(true);
            app.offers.update = {
                loading: true,
                action: function() {
                    var ao = app.offers;
                    ao.maxLayovers = values[0];
                    ao.resetFilters();
                    ao.applyFilter();
                }
            };
        } else {
            app.offers.maxLayovers = values[0];
        }
    });    
    
    // Модификация списка пассажиров
    this.persons.click = function(el) {
        var group = el.parent().attr('data-group');
        if (el.hasClass('selected')) {
            this.selected[group] = (group == 'adults') ? 1 : 0;
        } else {
            var value = el.attr('data-value');
            this.selected[group] = value ? parseInt(value, 10) : 0;
        }
        this.update();
    };
    this.persons.update = function() {
        var d = this.dropdown, s = this.selected;
        var correct = s.adults + s.children + s.infants < 9; 
        this.items.removeClass('selected');
        this.empty.removeClass('selected');
        $('.pg-adults dd', d).eq(s.adults - 1).addClass('selected');
        $('.pg-children dd', d).eq(s.children).addClass('selected').end().slice(1).each(function(i) {
            $(this).toggleClass('disabled', i > 7 - s.adults);
        });
        $('.pg-infants dd', d).eq(s.infants).addClass('selected').end().slice(1).each(function(i) {
            $(this).toggleClass('disabled', i > 7 - s.adults - s.children);
        });
        $('.excess', d).toggle(!correct);
        $('.a-button', d).toggle(correct);
        if (correct) {
            var template = '<span class="value">{nt}{gt}</span>';
            var nc = app.constant.numbers.collective;
            var result = [template.supplant({
                nt: nc[s.adults],
                gt: (s.children || s.infants) ? (' ' + app.utils.plural(s.adults, ['взрослый', 'взрослых', 'взрослых'])) : ''
            })];
            if (s.children) result.push(template.supplant({
                nt: nc[s.children] + ' ',
                gt: app.utils.plural(s.children, ['ребёнок', 'детей', 'детей'])
            }));
            if (s.infants) result.push(template.supplant({
                nt: nc[s.infants] + ' ',
                gt: app.utils.plural(s.infants, ['младенец', 'младенцев', 'младенцев'])
            }));
            this.values.html(' (' + result.enumeration() + ')').show();
            this.lastCorrect = $.extend({}, this.selected);
        }
    };
    this.persons.select = function(data) {
        this.selected = data;
        this.update();
    },
    this.persons.hide = function() {
        if ($('.excess', this.dropdown).is(':visible')) {
            this.selected = $.extend({}, this.lastCorrect);
        }
        $(window).unbind('click keydown', this.selfhide);
        this.dropdown.fadeOut(150);
        this.el.trigger('change', this.selected);
    };
    $('.a-button', this.persons.dropdown).click(function() {
        self.persons.hide();
    });    
    
    // Один пассажир по умолчанию
    search.persons.select({adults: 1, children: 0, infants: 0});    
    
    // Кнопка
    this.submit = $('#search-submit');
},
values: function() {
    var data = {
        from: this.from.val(),
        to: this.to.val(),
        rt: this.rt.value == 'rt' ? 1 : 0,
        date1: this.calendar.values[0],
        date2: this.calendar.values[1],
        adults: this.persons.selected.adults,
        cabin: this.cabin.selected,
        search_type: 'travel',
        day_interval: 1,
        debug: $('#sdmode').get(0).checked ? 1 : 0
    };
    return data;
},
update: function(source) {
    var self = this;
    clearTimeout(this.timer);
    if (source == this.calendar && this.dateparts && this.calendar.values[0] != this.dateparts[0].value) {
        var s = this.to.val();
        var pattern = new RegExp('(\\s*)' + this.dateparts[0].text + '(\\s*)', 'i');
        var result = s.replace(pattern, function(s, p1, p2) {return (p1 && p2) ? ' ' : '';});
        if (result != s) this.to.trigger('set', result);
    }
    this.timer = setTimeout(function() {
        self.validate();
    }, 750);
    this.toggle(false);    
},
validate: function(qkey) {
    clearTimeout(this.timer);
    var self = this, data = qkey ? {query_key: qkey} : {search: this.values()};
    this.toggle(false);
    this.abort();
    if (data.search && !data.search.to) return;
    this.request = $.get("/pricer/validate/", data, function(result, status, request) {
        if (request != self.request) return;
        if (result.valid) {
            app.offers.load(data, result.human);
            data.query_key ? app.offers.show() : self.toggle(true);
        }
        self.apply(result.complex_to_parse_results || {});
        delete(self.request);
    });
},
abort: function() {
    if (this.request && this.request.abort) {
        this.request.abort();
    }
    if (app.offers.loading.is(':visible')) {
        app.offers.container.addClass('g-none');
    }
    var au = app.offers.update;
    if (au && au.request && au.request.abort) {
        au.request.abort();
        delete(au.request);
    }
},
apply: function(data, str) {
    $('#search-to-label i').each(function() {
        var label = $(this);
        label.toggleClass('label-to', data[label.attr('data-key')] !== undefined);
    });
    if (data.dates) {
        this.dateparts = [];
        var str = this.to.val();
        for (var i = data.dates.length; i--;) {
            var dp = data.dates[i];
            this.dateparts[i] = {value: dp.value, text: str.substring(dp.start, dp.end + 1)};
        }
        this.calendar.select(data.dates);
    } else {
        delete(this.dateparts);
    }
},
toggle: function(mode) {
    this.submit.toggleClass('disabled', !mode);
}
};
