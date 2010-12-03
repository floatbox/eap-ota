var search = {
init: function() {
    var self = this;
    
    // Откуда
    this.from = $('#search-from').autocomplete({
        cls: 'autocomplete',
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
        if (offersList.results.is(':visible')) {
            self.toggle(true);
            offersList.update = {
                loading: true,
                action: function() {
                    var ao = offersList;
                    ao.maxLayovers = values[0];
                    ao.resetFilters();
                    ao.applyFilter();
                }
            };
        } else {
            offersList.maxLayovers = values[0];
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
        $('body').unbind('click keydown', this.selfhide);
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
        dates: this.calendar.values,
        people_count: this.persons.selected,
        changes: this.changes.value[0],
        cabin: this.cabin.value[0],
        search_type: 'travel',
        day_interval: 1,
        debug: $('#sdmode').get(0).checked ? 1 : 0
    };
    return data;
},
restore: function(data) {
    var df = this.defvalues;
    this.from.trigger('set', data.from || df.from || '');
    this.to.trigger('set', data.to || '');    
    this.calendar.selected = [];
    if (data.dates) {
        this.calendar.select(data.dates);
    } else {
        this.calendar.update();
    }
    this.persons.select($.extend({}, data.people_count || df.people_count));
    this.changes.select(data.changes || []);
    this.cabin.select(data.cabin || []);
    this.rt.set(data.rt !== undefined && data.rt == 0 ? 'ow' : 'rt');
},
update: function(source) {
    var self = this;
    clearTimeout(this.timer);
    if (source == this.calendar && this.parsed && this.parsed.dates) {
        var pd =  this.parsed.dates, improper = [];
        for (var i = pd.length; i--;) {
            if (pd[i].value != this.calendar.values[i]) improper.push(pd[i].str);
        }
        if (improper.length) {
            var current = this.to.val(); 
            var pattern = new RegExp('(\\s*)(?:' + improper.join('|') + ')(\\s*)', 'i');        
            var result = current.replace(pattern, function(s, p1, p2) {return (p1 && p2) ? ' ' : '';});
            if (result != current) this.to.trigger('set', result);
        }
    }
    this.timer = setTimeout(function() {
        self.validate();
    }, 750);
    this.toggle(false);    
},
validate: function(qkey) {
    clearTimeout(this.timer);
    if (this.preventValidation) return;
    this.toggle(false);
    this.abort();
    var self = this, data = qkey ? {query_key: qkey} : {search: this.values()};
    if (window._gaq && data.search) {
        _gaq.push(['_trackEvent', 'Search', 'To', data.search.to]);
    }
    this.request = $.get("/pricer/validate/", data, function(result, status, request) {
        if (request != self.request) return;
        if (data.query_key && result.search) {
            self.preventValidation = true;
            self.restore(result.search);
            setTimeout(function() {
                delete(self.preventValidation);
            }, 1000);
            self.apply(result.search.complex_to_parse_results || {});
        } else {
            self.apply(result.complex_to_parse_results || {});
        }
        if (result.valid) {
            var options = {
                query_key: result.query_key || data.query_key,
                search_type: 'travel'
            };
            if (data.query_key) {
                options.restore_results = true;
                offersList.load(options, result.human);
                offersList.show(false);
            } else {
                self.loadOptions = {options: options, title: result.human};
                self.toggle(true);
                self.loadTimer = setTimeout(function() {
                    clearTimeout(self.loadTimer);
                    if (self.loadOptions) {
                        offersList.load(self.loadOptions.options, self.loadOptions.title);
                        delete(self.loadOptions);
                    }
                }, 5000);
            }
        }
        if (result.search) {
            self.updateMap(result.search.from_as_object, result.search.to_as_object);
        }        
        delete(self.request);
    });
},
updateMap: function(lf, lt) {
    this.map.Clear();
    var pf = lf && lf.lat && lf.lng ? new VELatLong(lf.lat, lf.lng) : undefined;
    var pt = lt && lt.lat && lt.lng ? new VELatLong(lt.lat, lt.lng) : undefined;    
    if (pf) this.map.AddShape(new VEShape(VEShapeType.Pushpin, pf));
    if (pt) this.map.AddShape(new VEShape(VEShapeType.Pushpin, pt));
    if (pf && pt) {
        var route = new VEShape(VEShapeType.Polyline, [pf, pt]);
        route.SetLineWidth(3);
        route.SetLineColor(new VEColor(237, 17, 146, 0.75));
        route.HideIcon();
        this.map.AddShape(route);
        this.map.SetMapView([pf, pt]);
    } else {
        var ft = pf || pt;
        if (ft) this.map.SetCenterAndZoom(ft, 4);
    }
},
abort: function() {
    var r = this.request;
    if (r && r.abort) r.abort();
    offersList.abort();
},
apply: function(data) {
    this.parsed = data;
    $('#search-to-label i').each(function() {
        var label = $(this);
        label.toggleClass('label-to', data[label.attr('data-key')] !== undefined);
    });
    if (data.dates) {
        var dates = [];
        for (var i = data.dates.length; i--;) {
            dates[i] = data.dates[i].value;
        }
        this.calendar.select(dates);
    }
},
toggle: function(mode) {
    this.submit.toggleClass('disabled', !mode);
}
};
