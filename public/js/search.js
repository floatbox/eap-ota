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
        self.update(self.persons);
    });
    this.cabin.el.bind('change', function(e, values) {
        self.update(self.cabin);
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
        var correct = s.adults + s.children + s.infants < 7; 
        this.items.removeClass('selected');
        this.empty.removeClass('selected');
        $('.pg-adults dd', d).eq(s.adults - 1).addClass('selected');
        $('.pg-children dd', d).eq(s.children).addClass('selected').end().slice(1).each(function(i) {
            $(this).toggleClass('disabled', i > 5 - s.adults);
        });
        $('.pg-infants dd', d).eq(s.infants).addClass('selected').end().slice(1).each(function(i) {
            $(this).toggleClass('disabled', i > 5 - s.adults - s.children);
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
    this.sprogress = this.submit.find('.progress');
},
values: function() {
    var data = {
        from: this.from.val(),
        to: this.to.val(),
        rt: this.rt.value == 'rt' ? 1 : 0,
        dates: this.calendar.values,
        people_count: this.persons.selected,
        cabin: this.cabin.value[0],
        search_type: 'travel',
        day_interval: 1
    };
    var debug = $('#sdmode');
    if (debug.length && debug.get(0).checked) {
        data.debug = 1;
    }
    return data;
},
restore: function(data) {
    this.from.trigger('set', data.from || '').trigger('iata', '');
    this.to.trigger('set', data.to || '').trigger('iata', '');
    this.persons.select($.extend({}, data.people_count || df.people_count));
    this.cabin.select(data.cabin || []);
    this.calendar.selected = [];
    this.rt.set(data.rt !== undefined && data.rt == 0 ? 'ow' : 'rt');
    if (data.dates) {
        this.calendar.select(data.dates);
    }    
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
    if (source == this.persons && this.parsed && this.parsed.people_count) {
        var current = this.to.val(); 
        var pattern = new RegExp('(\\s*)(?:' + this.parsed.people_count.str + ')(\\s*)', 'i');
        var result = current.replace(pattern, function(s, p1, p2) {return (p1 && p2) ? ' ' : '';});
        if (result != current) this.to.trigger('set', result);
    }
    this.timer = setTimeout(function() {
        self.validate();
    }, 500);
},
validate: function(qkey) {
    clearTimeout(this.timer);
    clearTimeout(this.loadTimer);
    if (this.preventValidation) return;
    if (qkey) {
        var data = {query_key: qkey};
    } else {
        var values = this.values();
        var data = {search: values};
        var params = $.param(values);
        if (params != this.lastParams) {
            this.lastParams = params;
        } else {
            return;
        }
    }
    this.toggle(false);
    this.abort();
    if (window._gaq && data.search) {
        _gaq.push(['_trackEvent', 'Search', 'To', data.search.to]);
    }
    var self = this;
    var restoreResults = Boolean(qkey);
    this.sprogress.show();
    this.request = $.get('/pricer/validate/', data, function(result, status, request) {
        if (request != self.request) {
            return;
        }
        self.sprogress.hide();
        if (data.query_key && result.search) {
            self.preventValidation = true;
            self.restore(result.search);
            setTimeout(function() {
                self.preventValidation = false;
            }, 1000);
            self.apply(result.search.complex_to_parse_results || {});
        } else {
            self.apply(result.complex_to_parse_results || {});
        }
        if (result.valid) {
            offersList.nextUpdate = {
                title: result.human
            };
            offersList.nextUpdate.params = {
                query_key: result.query_key || data.query_key,
                search_type: 'travel'
            };
            if (restoreResults) {
                offersList.nextUpdate.params.restore_results = true;
                offersList.load();
                offersList.show(false);
            } else {
                self.toggle(true);
            }
        } else {
            delete(offersList.nextUpdate);
        }
        var rs = result.search;
        if (rs) {
            self.updateMap(rs.from_as_object, rs.to_as_object);
            if (rs.from_as_object) {
                self.from.trigger('iata', rs.from_as_object.iata);
            }
            if (rs.to_as_object) {
                self.to.trigger('iata', rs.to_as_object.iata);
            }
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
    if (data.people_count) {
        var pcv = data.people_count.value;
        this.persons.select({
            adults: pcv.adults || 1,
            children: pcv.children || 0,
            infants: pcv.infants || 0
        });
    }
},
toggle: function(mode) {
    this.submit.toggleClass('disabled', !mode);
}
};
