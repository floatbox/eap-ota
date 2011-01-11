var search = {
init: function() {
    var self = this;

    /* Режим (по умолчанию туда и обратно) */
    this.mode = 'rt';
    $('#search-fields .segment1 .sicon').click(function() {
        self.toggleMode();
    });
    $('#search-mode li').click(function() {
        self.toggleMode($(this).attr('data-mode'));
    });
    $('#search-fields .add-segment').click(function() {
        self.toggleMode('tw');
    });
    $('#search-fields .segment2 .remove-segment').click(function() {
        self.segments[1].from.trigger('set', self.segments[2].from.val());
        self.segments[1].to.trigger('set', self.segments[2].to.val());
        self.segments[2].from.trigger('set', '');
        self.segments[2].to.trigger('set', '');
        self.toggleMode('dw');
    });
    $('#search-fields .segment3 .remove-segment').click(function() {
        self.segments[2].from.trigger('set', '');
        self.segments[2].to.trigger('set', '');
        self.toggleMode('dw');
    });

    /* Поля */
    var searchField = function(selector) {
        var el = $(selector); 
        return el.autocomplete({
            cls: 'autocomplete',
            url: '/complete.json',
            root: 'data',
            width: 340,
            height: 374,
            loader: el.closest('td').find('.loader'),
            params: {
                limit: 30
            }
        }).change(function() {
            var el = $(this), v = el.val();
            if (v === '') el.trigger('iata', '');
            if (v !== el.data('pval')) self.update(this);
            el.data('pval', v);
        });
    };
    this.segments = [{
        from: searchField('#search-s1-from'),
        to: searchField('#search-s1-to')
    }, {
        from: searchField('#search-s2-from'),
        to: searchField('#search-s2-to')
    }, {
        from: searchField('#search-s3-from'),
        to: searchField('#search-s3-to')
    }];
    
    // IATA в первом поле «Откуда»
    var fdata = this.segments[0].from.get(0).onclick();
    if (fdata && fdata.iata) {
        this.segments[0].from.trigger('iata', fdata.iata);
    }    
    
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
    this.submit = $('#search-submit').attr('data-required', 'to');
    this.smessage = this.submit.find('.message');
    this.sprogress = this.submit.find('.progress');
    this.submit.find('.b-submit').click(function(event) {
        event.preventDefault();
        if (offersList.nextUpdate) {
            offersList.load();
            offersList.show();
        }
    }).mouseover(function() {
        if (self.submit.is('.disabled:not(.current)')) {
            self.smessage.fadeIn(150);
        }
    }).mouseout(function() {
        if (self.smessage.is(':visible')) {
            self.smessage.fadeOut(150);
        }
    });
    this.messages = {
        from_iata: 'Введите, пожалуйста, пункт отправления',
        to_iata: 'Введите, пожалуйста, пункт назначения',
        date: 'Выберите, пожалуйста, дату вылета',
        date2rt: 'Выберите, пожалуйста, дату обратного вылета'
    };
    this.smessage.find('.ssm-content').html(this.messages.to);
},
toggleMode: function(mode) {
    var context = $('#search-fields');
    if (mode === undefined) {
        mode = {rt: 'ow', ow: 'rt'}[this.mode] || this.mode;
    } else if (mode === 'mw') {
        mode = this.segments[2].from.val() || this.segments[2].to.val() ? 'tw' : 'dw';
    }
    if (mode !== this.mode) {
        context.removeClass(this.mode + 'mode').addClass(mode + 'mode');
        context.find('tr.segment2').toggleClass('g-none', mode !== 'dw' && mode !== 'tw');
        context.find('tr.segment3').toggleClass('g-none', mode !== 'tw');
        context.find('.autocomplete:visible[value=""]').eq(0).focus();
        this.calendar.toggleMode(mode);
        this.mode = mode;
    }
},
values: function() {
    var s = this.segments;
    var d = this.calendar.values || [];
    var data = {
        form_segments: [],
        people_count: this.persons.selected,
        cabin: this.cabin.value[0],
        search_type: 'travel',
        day_interval: 1
    };
    for (var i = {rt: 1, ow: 1, dw: 2, tw: 3}[this.mode]; i--;) {
        data.form_segments[i] = {
            from: s[i].from.val(),
            to: s[i].to.val(),
            date: d[i]
        }; 
    }
    if (this.mode === 'rt') {
        data.form_segments[1] = {
            from: data.form_segments[0].to,
            to: data.form_segments[0].from,
            date: d[1]
        };
    }
    var debug = $('#sdmode');
    if (debug.length && debug.get(0).checked) {
        data.debug = 1;
    }
    return data;
},
restore: function(data) {
    var fs = data.form_segments;
    for (var i = fs.length; i--;) {
        this.segments[i].from.trigger('set', fs[i].from || '').trigger('iata', '');
        this.segments[i].to.trigger('set', fs[i].to || '').trigger('iata', '');
    }
    this.toggleMode(['ow', 'rt', 'mw'][fs.length]);
    this.persons.select($.extend({}, data.people_count || df.people_count));
    this.cabin.select(data.cabin || []);
    this.calendar.selected = [];
    if (data.dates) {
        this.calendar.select(data.dates);
    }    
},
update: function(source) {
    clearTimeout(this.timer);
    var self = this;
    if (this.parsed) {
        var current = this.segments[0].to.val(), result = current, pattern;
        if (source == this.calendar && this.parsed.dates) {
            var pd =  this.parsed.dates, improper = [];
            for (var i = pd.length; i--;) {
                if (pd[i].value != this.calendar.values[i]) improper.push($.trim(pd[i].str));
            }
            if (improper.length) {
                pattern = new RegExp(improper.join('|'), 'i');
                result = result.replace(pattern, '');
            }
        }
        if (source == this.persons && this.parsed.people_count) {
            pattern = new RegExp($.trim(this.parsed.people_count.str), 'i');
            result = result.replace(pattern, '');
        }
        if (result != current) {
            result = result.replace(/\s(?=\s)|$\s/g, '');
            this.segments[0].to.trigger('set', result);
        }
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
    this.submit.addClass('validating');

    this.request = $.get('/pricer/validate/', data, function(result, status, request) {
        if (request != self.request) {
            return;
        }
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
        self.submit.removeClass('current validating');
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
            if (result.errors) {
                for (var i = 0, im = result.errors.length; i < im; i++) {
                    var err = result.errors[i];
                    if (err.length) {
                        var mid = err[0], fmid = mid + (i + 1) + self.mode;
                        var mtext = self.messages[fmid] || self.messages[mid];
                        self.smessage.find('.ssm-content').html(mtext);
                        break;
                    }
                }
            }
        }
        var fs = result.search && result.search.form_segments;
        if (fs) {
            var sfrom, sto, segments = [];
            for (var i = 0, im = Math.min(fs.length, {ow: 1, rt: 2, dw: 2, tw: 3}[self.mode]); i < im; i++) {
                sfrom = fs[i].from_as_object, sto = fs[i].to_as_object;
                self.segments[i].from.trigger('iata', sfrom ? (sfrom.code = sfrom.iata || sfrom.alpha2) : '');
                self.segments[i].to.trigger('iata', sto ? (sto.code = sto.iata || sto.alpha2) : '');                
                segments[i] = {from: sfrom, to: sto};
            }
            if (self.map) {
                self.updateMap(segments);
            }
        }        
        delete(self.request);
    });
},
updateMap: function(segments) {
    this.map.Clear();
    var pins = [], lines = [], colors = [];
    colors[0] = new VEColor(129, 170, 0, 0.9);
    colors[1] = new VEColor(196, 111, 38, 0.9);
    colors[2] = new VEColor(10, 160, 198, 0.9);
    colors[3] = new VEColor(237, 17, 146, 0.75);
    for (var i = 0, im = segments.length; i < im; i++) {
        var f = segments[i].from, t = segments[i].to;
        var fp = f && f.lat && f.lng && new VELatLong(f.lat, f.lng);
        var tp = t && t.lat && t.lng && new VELatLong(t.lat, t.lng);
        if (fp) pins.push(fp);
        if (tp) pins.push(tp);
        if (fp && tp) {
            lines.push({points: [fp, tp], color: colors[i]});
        }
    }
    if (this.mode === 'rt' && lines.length === 2) {
        lines[1].color = new VEColor(196, 111, 38, 0.5);        
    }
    for (var i = 0, im = lines.length; i < im; i++) {
        var route = new VEShape(VEShapeType.Polyline, lines[i].points);
        route.SetLineWidth(3);
        route.SetLineColor(lines[i].color);
        route.HideIcon();
        this.map.AddShape(route);
    }
    /*for (var i = 0, im = pins.length; i < im; i++) {
        this.map.AddShape(new VEShape(VEShapeType.Pushpin, pins[i]));
    }*/
    if (pins.length > 1) {
        this.map.SetMapView(pins);
    } else if (pins.length) {
        this.map.SetCenterAndZoom(pins[0], 4);
    }
},
abort: function() {
    var r = this.request;
    if (r && r.abort) r.abort();
},
apply: function(data) {
    this.parsed = data;
    $('#search-s1-to').closest('td').find('label span').each(function() {
        var fragment = $(this);
        fragment.toggleClass('highlight', data[fragment.attr('data-key')] !== undefined);
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
