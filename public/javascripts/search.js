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
            if (v !== el.data('pval')) {
                self.update(this);
                if (window._gaq && v) {
                    _gaq.push(['_trackEvent', 'Search', el.attr('data-label'), v]);
                }
            }
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
    this.toValues = [];
    
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
        fixedBlocks.update();
    });
    this.cabin.el.bind('change', function(e, values) {
        self.update(self.cabin);
        fixedBlocks.update();
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
        var manyinf = s.infants > s.adults;
        var manyall = s.adults + s.children + s.infants > 8;
        this.items.removeClass('selected');
        this.empty.removeClass('selected');
        $('.pg-adults dd', d).eq(s.adults - 1).addClass('selected');
        $('.pg-children dd', d).eq(s.children).addClass('selected').end().slice(1).each(function(i) {
            $(this).toggleClass('disabled', i > 7 - s.adults);
        });
        $('.pg-infants dd', d).eq(s.infants).addClass('selected').end().slice(1).each(function(i) {
            $(this).toggleClass('disabled', i > 7 - s.adults - s.children || i > s.adults - 1);
        });
        $('.excess', d).toggle(manyall);
        $('.infants', d).toggle(manyinf && !manyall);
        $('.a-button', d).toggle(!manyall && !manyinf);
        if (!manyall && !manyinf) {
            var template = '<span class="value">{nt}{gt}</span>';
            var nc = constants.numbers.collective;
            var result = [template.supplant({
                nt: nc[s.adults],
                gt: (s.children || s.infants) ? s.adults.inflect(' взрослый', ' взрослых', ' взрослых', false) : ''
            })];
            if (s.children) result.push(template.supplant({
                nt: nc[s.children] + ' ',
                gt: s.children.inflect('ребёнок', 'детей', 'детей', false)
            }));
            if (s.infants) result.push(template.supplant({
                nt: nc[s.infants] + ' ',
                gt: s.infants.inflect('младенец', 'младенцев', 'младенцев', false)
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
        this.calendar.toggleMode(mode);
        this.mode = mode;
        this.autoFrom();
        context.find('.autocomplete:visible[value=""]').eq(0).focus();
        fixedBlocks.update();
    }
},
values: function() {
    var s = this.segments;
    var d = this.calendar.values || [];
    var data = {
        form_segments: [],
        people_count: this.persons.selected,
        cabin: this.cabin.value[0],
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
    var sirena = $('#sirena');
    if (sirena.length && sirena.get(0).checked) {
        data.sirena = 1;
    }
    return data;
},
restore: function(data) {
    var segments = data.form_segments || [], dates = [];
    this.toggleMode(data.rt ? 'rt' : ['rt', 'ow', 'dw', 'tw'][segments.length]);
    for (var i = 0, im = this.segments.length; i < im; i++) {
        var segment = segments[i];
        this.segments[i].from.trigger('set', segment && segment.from || '').trigger('iata', '');
        this.segments[i].to.trigger('set', segment && segment.to || '').trigger('iata', '');
        if (segment && segment.date) {
            dates.push(segment.date);
        }
    }
    this.persons.select($.extend({}, data.people_count));
    this.cabin.select(data.cabin || []);
    this.calendar.selected = [];
    if (dates.length) {
        this.calendar.select(dates);
    } else {
        this.calendar.update();
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
                query_key: result.query_key || data.query_key
            };
            if (restoreResults) {
                offersList.nextUpdate.params.restore_results = true;
                offersList.load();
                offersList.show(false);
            } else {
                self.toggle(true);
                if (typeof self.onValid === 'function') {
                    self.onValid();
                }
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
        this.toValues = [];
        if (result.search && result.search.form_segments) {
            self.applySegments(result.search.form_segments);
        }
        delete(self.request);
    });
},
applySegments: function(segments) {
    var items = [];
    for (var i = 0, im = segments.length; i < im; i++) {
        var sf = segments[i].from_as_object;
        var st = segments[i].to_as_object;
        if (sf) sf.code = sf.iata || sf.alpha2;
        if (st) st.code = st.iata || st.alpha2;
        this.segments[i].from.trigger('iata', sf && this.segments[i].from.val() ? sf.code : '');
        this.segments[i].to.trigger('iata', st && this.segments[i].to.val() ? st.code : '');
        this.toValues[i] = st && st.name_ru;
        items[i] = {from: sf, to: st};
    }
    for (var i = 1; i < 3; i++) {
        this.segments[i].to.closest('td').find('label').toggleClass('highlight', Boolean(segments[i] && segments[i].to_as_object));
    }
    this.autoFrom();
    if (this.map.active) {
        this.map.show(items);
    } else {
        this.map.deferred = items;
    }    
},
autoFrom: function() {
    if (this.mode === 'dw' || this.mode === 'tw') {
        for (var i = 1, im = this.mode === 'tw' ? 3 : 2; i < im; i++) {
            var field = this.segments[i].from;
            if (!field.val() && this.toValues[i - 1] && !field.hasClass('autocomplete-focus')) {
                field.trigger('set', this.toValues[i - 1]);
            }
        }
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

/* Share */
search.share = {
init: function() {
    if (typeof Ya === 'undefined') {
        return false;
    }
    this.obj = new Ya.share({
        element: 'ya-share',
        elementStyle: {
            type: 'link',
            linkIcon: false,
            border: false,
            quickServices: ['facebook', 'twitter', 'friendfeed', 'lj', 'vkontakte', 'odnoklassniki', 'yaru']
        },
        popupStyle: {
            copyPasteField: true,
            blocks: {
               'Поделитесь с друзьями': ['facebook', 'twitter', 'friendfeed', 'lj', 'vkontakte', 'odnoklassniki', 'yaru', 'gbuzz', 'juick', 'moikrug', 'moimir', 'blogger', 'linkedin']
            }
        }
    });
}
};
