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
        segments: [{dpt: 'Москва'}],
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
    var lw = local.swarnings;
    var warnings = [];
    var segments = [];
    for (var i = 0; i < this.locations.used; i++) {
        var segment = this.locations.segments[i];
        var dpt = segment.dpt.selected;
        var arv = segment.arv.selected;
        var title = mode === 'mw' ? lw.mwsegments[i] : '';
        var s = {
            from: dpt ? dpt.name : '',
            to: arv ? arv.name : ''
        };
        if (!s.from) {
            warnings.push(lw.dpt.absorb(title));
        }
        if (!s.to) {
            warnings.push(lw.arv.absorb(title));
        }
        segments[i] = s;
    }
    if (mode === 'rt') {
        segments[1] = {from: segments[0].to, to: segments[0].from};
    }
    for (var i = 0; i < segments.length; i++) {
        var sdate = this.dates.selected[i];
        var title = lw[mode === 'mw' ? 'mwsegments' : 'rtsegments'][i];
        if (sdate === undefined) warnings.push(lw.date.absorb(title));
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
        warnings.push(lw.persons);
    }
    if (persons.infants > persons.adults) {
        warnings.push(lw.infants);
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
        children.select(data.options.children);
        infants.select(data.options.infants);
        adults.select(data.options.adults);
        cabin.select(data.options.cabin);
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
        Queries.history.select();
        page.location.set('search');
        page.title.set();
    }
    results.header.hide();
    if (values.warnings.length) {
        results.header.show(values.warnings[0], false);
    }
    delete values.warnings;
    this.loadSummary({
        search: values
    });
},
loadSummary: function(values, process) {
    var that = this;
    this.request = $.ajax({
        method: 'GET',
        url: '/pricer/validate/',
        data: values,
        success: function(data, status, request) {
            if (data.valid) {
                results.update(data);
            }
            if (values.query_key) {
                that.restoreValues(data);
                if (process !== false && results.data) {
                    results.load();
                }
            }
            that.locations.toggleLeave(data.map_segments[0].leave);
            if (that.map.api) {
                that.map.show(data.map_segments);
            } else {
                that.map.deferred = data.map_segments;
            }
        },
        error: function() {
            results.header.show('Не удалось соединиться с сервером', false);
        },
        timeout: 15000
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
        search.locations.toggleSegments(mode === 'mw' ? search.locations.countUsed() : 1);
        search.process();
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

/* Share */
search.share = {
init: function() {
    if (typeof Ya === 'undefined') {
        return false;
    }
    this.obj = new Ya.share({
        element: 'ya-share',
        description: 'Здесь можно найти, сравнить, выбрать и купить билеты на рейсы более 200 авиакомпаний всего мира по низкой цене.',
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
