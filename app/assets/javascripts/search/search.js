/* Form */
var search = {
init: function() {
    this.el = $('#search');
    this.mode.init();
    this.locations.init();
    this.options.init();
    this.dates.init();
    this.map.init();
    this.defaultValues = {
        segments: [],
        options: {
            adults: 1,
            children: 0,
            infants: 0,
            cabin: 'Y'
        }
    };
},
waitRequests: function() {
    var that = this, ls = search.locations.segments;
    $.when(ls[0].dpt.request, ls[0].arv.request).then(function() {
        that.active = true;
        that.process();
    });
},
getValues: function() {
    var mode = this.mode.selected;
    var warnings = [];
    var segments = [];
    for (var i = 0; i < this.locations.used; i++) {
        var segment = this.locations.segments[i];
        var dpt = segment.dpt.selected;
        var arv = segment.arv.selected;
        var title = mode === 'mw' ? I18n.t('search.messages.segments.mw', {number: I18n.t('search.messages.segments.numbers').split(' ')[i]}) : '';
        var s = {
            from: dpt ? dpt.name : '',
            to: arv ? arv.name : ''
        };
        if (!s.from) {
            warnings.push(I18n.t('search.messages.dpt', {segment: title}));
        }
        if (!s.to) {
            warnings.push(I18n.t('search.messages.arv', {segment: title}));
        }
        segments[i] = s;
    }
    if (mode === 'rt') {
        segments[1] = {from: segments[0].to, to: segments[0].from};
    }
    for (var i = 0; i < segments.length; i++) {
        var sdate = this.dates.selected[i];
        if (sdate === undefined) {
            var title;
            if (mode === 'mw') {
                title = I18n.t('search.messages.segments.mw', {number: I18n.t('search.messages.segments.numbers').split(' ')[i]});
            } else {
                title = I18n.t(i === 0 ? 'search.messages.segments.dpt' : 'search.messages.segments.rt');
            }
            warnings.push(I18n.t('search.messages.date', {segment: title}));
        }
        segments[i].date = this.dates.getDate(sdate);
    }
    if (this.mode.values.is(':visible')) {
        this.mode.hide();
    }
    var persons = {
        adults: this.options.adults.selected || 1,
        children: this.options.children.selected || 0,
        infants: this.options.infants.selected || 0
    };
    if (persons.adults + persons.children + persons.infants > 8) {
        warnings.push(I18n.t('search.messages.persons'));
    }
    if (persons.infants > persons.adults) {
        warnings.push(I18n.t('search.messages.infants'));
    }
    return {
        warnings: warnings,
        segments: segments,
        people_count: persons,
        cabin: this.options.cabin.selected
    };
},
setValues: function(data) {
    for (var i = this.locations.segments.length; i--;) {
        var segment = data.segments[i];
        if (!segment || segment.rt) {
            segment = {};
        }
        with (this.locations.segments[i]) {
            dpt.set(segment.dpt || '');
            arv.set(segment.arv || '');
        }
    }
    if (data.segments.length < 2) {
        this.mode.select('ow');
    } else if (data.segments[1].rt) {
        this.mode.select('rt');
    } else {
        this.mode.select('mw');
    }
    var dates = [], dateError = false;
    for (var i = data.segments.length; i--;) {
        var index = this.dates.dmyIndex[data.segments[i].date];
        if (index === undefined) {
            dateError = true;
            break;
        }
        dates[i] = index;
    }
    if (dateError) {
        dates = [];    
    }
    this.dates.setSelected(dates);
    with (this.options) {
        children.select(data.options.children || 0);
        infants.select(data.options.infants || 0);
        adults.select(data.options.adults || 1);
        cabin.select(data.options.cabin || 'Y');
    }
    return !dateError;
},
process: function() {
    clearTimeout(this.vtimer);
    if (this.active) {
        var that = this;
        this.vtimer = setTimeout(function() {
            that.validate();
        }, 100);
    }
},
validate: function() {
    var values = this.getValues();
    // Сбрасываем текущий поиск
    if (page.location.search) {
        page.location.set('search');
        page.title.set();
    }
    results.header.hide();
    this.valid = values.warnings.length === 0;
    if (!this.valid) {
        results.header.show(values.warnings[0], false);
    }
    delete values.warnings;
    this.loadSummary({
        search: values
    });
},
loadSummary: function(values, process) {
    var that = this;
    if (this.valid) {
        results.header.wait();
    } else if (values.query_key) {
        this.valid = true;
    }
    this.request = $.ajax({
        method: 'GET',
        url: '/pricer/validate/',
        data: values,
        success: function(data, status, request) {
            if (that.valid && data.valid) {
                results.update(data);
                if (!values.query_key) {
                    _kmq.push(['record', 'SEARCH: button enabled']); // Для восстановления формы по урлу не считаем
                }
            }
            if (values.query_key) {
                if (data.valid) {
                    that.restoreValues(data);
                    if (process !== false && results.data) {
                        results.load();
                    }
                } else {
                    setTimeout(function() {
                        results.message.el.hide();
                        results.content.el.hide();
                        results.filters.hide();
                        results.header.edit.hide();                    
                        results.header.buttonEnabled.hide();
                        results.header.button.show();
                        results.header.el.removeClass('rh-fixed');
                        search.el.show()
                        search.map.resize();
                        search.map.load();
                        search.setValues(search.defaultValues);
                        search.mode.select('rt');
                        search.active = true;
                        search.validate();
                        page.loadLocation();
                        $w.scrollTop(0);                        
                    }, 100);
                }
            }
            if (data.map_segments) {
                that.locations.toggleLeave(data.map_segments[0].leave);
                if (that.map.api) {
                    that.map.showSegments(data.map_segments);
                } else {
                    that.map.deferred = data.map_segments;
                }
            }
        },
        error: function() {
            results.header.show(I18n.t('timeout'), false);
        },
        timeout: 45000
    });
},
restoreValues: function(data) {
    this.setValues(data);
    this.mode.select(data.segments.length === 1 ? 'ow' : (data.segments[1].rt ? 'rt' : 'mw'));
    if (!this.dates.selected.length) {
        delete results.data;
        this.validate();
    }
}
};

/* Options */
search.options = {
init: function() {
    var that = this;
    this.el = $('#search-options');
    this.el.find('.so-persons').each(function() {
        that[$(this).attr('data-name')] = new search.Option(this, true);
    });
    this.cabin = new search.Option(this.el.find('.so-cabin'));
}
};

/* Option constructor */
search.Option = function(selector, integer) {
    this.el = $(selector);
    this.integer = integer;
    this.init();
    return this;
};
search.Option.prototype = {
init: function() {
    var that = this;
    this.items = this.el.find('.so-values li');
    this.index = {};
    this.items.each(function(i) {
        var item = $(this);
        var value = item.attr('data-value');
        if (value === undefined) {
            value = item.text();
            item.attr('data-value', value);
        }
        that.index[value] = i;
    });
    this.el.delegate('.so-values li', 'click', function() {
        that.select($(this).attr('data-value'));
    });
},
select: function(val) {
    var value = this.integer ? parseInt(val, 10) : val;
    if (value !== this.selected) {
        this.items.removeClass('selected').eq(this.index[val.toString()]).addClass('selected');
        this.selected = value;
        search.process();
    }

}
};

/* Mode */
search.mode = {
init: function() {
    this.el = $('#search-mode');
    this.initList();
    this.initIcon();
    this.activate();
},
initList: function() {
    var that = this;
    this.control = this.el.find('.sm-control').click(function() {
        that.show();
    });
    this.values = this.el.find('.sm-values').mousedown(function(event) {
        event.stopPropagation();
    });
    this.values.find('li').click(function() {
        that.select($(this).attr('data-mode'), true);
    });
},
initIcon: function() {
    var that = this;
    $('#search-locations .sl-segment1 .sl-icon').click(function() {
        var current = that.selected;
        if (current === 'ow') that.select('rt', true);
        if (current === 'rt') that.select('ow', true);
    });
},
activate: function() {
    var that = this;
    var hide = function(event) {
        if (event.type === 'mousedown' || event.which === 27) that.hide();
    };
    this.hide = function() {
        that.values.fadeOut(200);
        $(document).unbind('keydown mousedown', hide);
    };
    this.show = function() {
        that.values.fadeIn(200);
        setTimeout(function() {
            $(document).bind('keydown mousedown', hide);
        }, 10);
    };
},
select: function(mode, focus) {
    if (mode !== this.mode) {
        var sv = this.values.find('li[data-mode="' + mode + '"]');
        this.values.find('.selected').removeClass('selected');
        this.control.html(sv.addClass('selected').html());
        this.selected = mode;
        if (mode !== 'mw' && search.map.pricesMode) {
            search.map.loadPrices();
        } else {
            search.locations.toggleSegments(mode === 'mw' ? search.locations.countUsed() : 1);
            search.process();
        }
    }
    if (this.values.is(':visible')) {
        var that = this;
        setTimeout(function() {
            that.hide();
        }, 300);
    } else {
        this.values.hide();
    }
    if (focus) {
        search.locations.focusEmpty();
    }
}
};
