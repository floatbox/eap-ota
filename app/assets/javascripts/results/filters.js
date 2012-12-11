/* Filters */
results.filters = {
init: function() {
    var that = this;    
    this.el = $('#results-filters');
    this.groups = [];
    this.el.find('.rf-group').mousedown(function(event) {
        event.stopPropagation();
    }).each(function() {
        var group = new filtersGroup(this);
        that.groups.push(group);
    });
    this.el.on('click', '.rfv-item', function() {
        that.select($(this));
    });
    this.el.on('click', '.rfv-empty:not(.rfv-selected)', function() {
        that.reset($(this));
    });
    this.observe = function(event) {
        if (event.type !== 'keydown' || event.which === 27) that.hideGroup();
    }
    this.groups[3].updateCustomLists = function() {
        var slider = results.durationSlider;
        slider.init();
        slider.group = that.groups[3];
        slider.group.lists.push(slider);
        that.lists.push(slider);
        var checkbox = results.onestopCheckbox;
        checkbox.init();
        checkbox.group = that.groups[3];
        checkbox.group.lists.push(checkbox);
        that.lists.push(checkbox);    
    };
},
show: function(smooth) {
    if (smooth) {
        var el = this.el;
        el.css('overflow', 'hidden').height(12).show();
        el.animate({height: 34}, 250, function() {
            el.css('overflow', '').height('');
        });
    } else {
        this.el.show();
    }
},
hide: function(smooth) {
    if (smooth) {
        var el = this.el;
        el.css('overflow', 'hidden');
        el.animate({height: 12}, 250, function() {
            el.hide().css('overflow', '').height('');
        });
    } else {
        this.el.hide();
    }
},
getVariants: function() {
    var features = [];
    var offers = results.all.offers;
    for (var o = offers.length; o--;) {
        var variants = offers[o].variants;
        for (var v = variants.length; v--;) {
            features.push(variants[v].features);
        }
    }
    this.variants = features;
},
showGroup: function(group) {
    var observe = this.observe;
    if (this.visible && this.visible !== group) {
        this.visible.content.hide();
    } else {
        setTimeout(function() {
            $(document).on('keydown mousedown', observe);
        }, 10);
    }
    if (!group.resized) {
        group.resize();
    }
    this.visible = group;
    //group.content.fadeIn(150); в файрфоксе во время анимации мигает текст
    group.content.show();
},
hideGroup: function() {
    $(document).off('keydown mousedown', this.observe);
    if (this.visible) {
        //this.visible.content.fadeOut(100);
        this.visible.content.hide();
        delete this.visible;
    }
},
update: function() {
    this.lists = [];
    for (var i = this.groups.length; i--;) {
        var group = this.groups[i];
        group.update();
        this.lists = this.lists.concat(group.lists);        
    }
    this.getVariants();
},
getConditions: function(except) {
    var check = function() {
        return true;
    };
    var conditions = [];
    for (var i = this.lists.length; i--;) {
        var list = this.lists[i];
        if (list.key !== except && list.conditions) {
            conditions.push(list.conditions);
        }
    }
    if (conditions.length !== 0) {
        var jc = conditions.sort(function(a, b) {return a.length - b.length;}).join(' && ');
        check = new Function('f', 'return ' + jc + ';');
        check.hash = jc;
    }
    return check;
},
getProper: function(check) {
    var proper = [];
    var variants = this.variants;
    for (var v = variants.length; v--;) {
        var features = variants[v];
        if (check(features)) {
            proper.push(features.all);
        }
    }
    return proper.join(' ') + ' ';
},
apply: function() {
    clearTimeout(this.htimer);
    var conditions = this.getConditions();
    results.all.filter(conditions);
    results.updateFeatured();
    if (results[results.content.selected].control.hasClass('rt-disabled')) {
        results.content.selectFirst();
    } else {
        results.fixed.update();
    }
    this.toggle();
    var that = this;
    this.htimer = setTimeout(function() {
        that.hideGroup();
    }, 750);
    $w.delay(100).smoothScrollTo(0, 300);
},
toggle: function() {
    var cached = {};
    for (var i = this.lists.length; i--;) {
        var list = this.lists[i];
        var check = this.getConditions(list.key);
        if (check.hash) {
            var proper = cached[check.hash]; // Оптимизируем одинаковые наборы фильтров
            if (!proper) {
                proper = this.getProper(check);
                cached[check.hash] = proper;
            }
            list.toggle(proper);
        } else {
            list.toggle(); // Если нет выбранных фильтров
        }
    }
},
toggleDisabled: function(disabled) {
    for (var i = this.groups.length; i--;) {
        var group = this.groups[i];
        group.control.toggleClass('rfg-disabled', disabled || group.columns === 0);
    }
},
select: function(item) {
    if (item.hasClass('rfv-disabled')) {
        results.filters.resetAll();
    }
    item.toggleClass('rfv-selected');
    var list = item.closest('.rf-values');
    var items = list.find('.rfv-item');
    var selected = items.filter('.rfv-selected').length;
    if (selected === items.length) {
        this.reset(list.find('.rfv-empty'));
    } else {
        list.find('.rfv-empty').toggleClass('rfv-selected', selected === 0);
    }
    item.closest('.rf-list').data('list').apply();
},
reset: function(item) {
    item.addClass('rfv-selected').siblings().removeClass('rfv-selected');
    item.closest('.rf-list').data('list').apply();
},
resetAll: function() {
    for (var i = this.lists.length; i--;) {
        this.lists[i].reset();
    }
    for (var i = this.groups.length; i--;) {
        this.groups[i].counter.hide();
    }
}
};

/* Filters group */
var filtersGroup = function(selector) {
    var context = $(selector);
    this.control = context.find('.rfg-control').data('group', this);
    this.content = context.find('.rfg-content');
    this.id = context.attr('data-id');
    this.init();
};
filtersGroup.prototype = {
init: function() {
    var that = this;
    this.lists = [];
    this.counter = this.control.find('.rfg-counter');
    this.counter.click(function(event) {
        event.stopPropagation();
        that.reset();
    });
    this.control.click(function() {
        var visible = results.filters.visible;
        if (that === visible) {
            results.filters.hideGroup();
        } else if (!that.control.hasClass('rfg-disabled')) {
            results.filters.showGroup(that);
        }
    });
},
update: function() {
    var that = this;
    var source = $('#rfg-' + this.id);
    this.columns = source.find('.rfg-column').length;
    this.content.html(source.html() || '');
    this.lists = [];
    this.content.find('.rf-list').each(function() {
        var list = new results.filtersList(this);
        list.group = that;
        that.lists.push(list);
    });
    if (this.updateCustomLists) {
        this.updateCustomLists();
    }
    var label = this.content.find('.rfg-label').html();
    if (label) {
        this.control.find('.rfg-label').html(label.capitalize());
    }
    this.control.toggleClass('rfg-disabled', this.columns === 0);
    this.counter.hide();
    delete this.resized;
    source.remove();
},
resize: function() {
    var columns = this.content.find('.rfg-column');
    var width = columns.length * 190;
    if (width > 982) {
        var cw = Math.floor(982 / columns.length);
        width = cw * columns.length;
        columns.width(cw - 6);
    } else {
        columns.width('');
    }
    var tw = this.control.width();
    var tab = $('<div class="rfg-tab"></div>').width(tw).appendTo(this.content);
    if (width < tw + 14) {
        width = tw + 14;
    }
    var offset = this.control.offset().left - results.filters.el.offset().left;
    if (offset + width > 982) {
        var shift = offset + width - 982;
        this.content.css('left', -shift);
        tab.css('left', shift);
    }
    this.content.width(width);
    this.resized = true;
},
apply: function() {
    var counter = 0;
    for (var i = this.lists.length; i--;) {
        if (this.lists[i].conditions) counter++;
    }
    this.counter.attr('title', counter ? lang.filters.reset.absorb(counter.declineArray(lang.filters.selected)) : '');
    this.counter.css('background-position', '0 ' + (-counter * 20) + 'px');
    this.counter.toggle(counter !== 0);
},
reset: function() {
    this.counter.hide();
    for (var i = this.lists.length; i--;) {
        this.lists[i].reset();
    }
    results.filters.apply();      
}
};

/* Filters list */
results.filtersList = function(selector) {
    this.el = $(selector).data('list', this);
    this.init();
};
results.filtersList.prototype = {
init: function() {
    this.values = this.el.find('.rfv-item');
    this.key = this.el.attr('data-key');
},
apply: function() {
    var key = this.key, conditions = [];
    this.values.filter('.rfv-selected').each(function() {
        var value = $(this).attr('data-value');
        conditions.push('f["' + key + value + '"]');
    });
    if (conditions.length) {
        this.conditions = '(' + conditions.join(' || ') + ')';
    } else {
        this.conditions = undefined;
    }
    this.group.apply();
    results.filters.apply();
},
toggle: function(proper) {
    var key = this.key;
    if (proper) {
        this.values.each(function() {
            var item = $(this);
            item.toggleClass('rfv-disabled', proper.indexOf(key + item.attr('data-value')) === -1);
        });
    } else {
        this.values.removeClass('rfv-disabled');
    }
},
reset: function() {
    this.el.find('.rfv-selected').removeClass('rfv-selected');
    this.el.find('.rfv-empty').addClass('rfv-selected');
    this.conditions = undefined;
}
};

/* Duration */
results.durationSlider = {
init: function() {
    var that = this;
    this.el = results.filters.el.find('.rf-duration');
    this.value = this.el.find('.rfd-value');
    this.selected = {
        el: this.el.find('.rfd-selected')
    };
    this.enabled = {
        el: this.el.find('.rfd-enabled')
    };
    this.marks = this.el.find('.rfd-marks');
    this.sliders = this.el.find('.rfd-slider');
    this.sliders.mousedown(function(event) {
        that.drag($(this).attr('data-name'), event);
    });
    this.el.find('.rfd-control').click(function(event) {
        that.click(event.pageX);
    });
    this.$move = function(event) {
        that.move(event.pageX);
    };
    this.$drop = function(event) {
        that.drop();
    };
    this.key = 'lduration';
    this.width = 161;
    this.update();
},
update: function() {
    this.from = Number(this.el.attr('data-min'));
    this.size = Number(this.el.attr('data-max')) - this.from;
    this.scale = this.width / this.size;
    this.marks.html('');
    for (var i = this.size + 1; i--;) {
        $('<div class="rfd-mark"></div>').css('left', Math.round(i * this.scale)).appendTo(this.marks);
    }
    this.reset();
},
reset: function() {
    var s = this.selected;
    this.enabled.min = s.min = 0;
    this.enabled.max = s.max = this.size;
    this.show(s.min, s.max);
    this.conditions = undefined;
},
click: function(x) {
    var s = this.selected;
    var e = this.enabled;
    var value = Math.round((x - this.el.offset().left - 3) / this.scale);
    if (value - s.min < s.max - value) {
        s.min = value.constrain(0, Math.min(s.max, e.max) - 1);
    } else {
        s.max = value.constrain(Math.max(s.min, e.min) + 1, this.size);
    }
    this.show(s.min, s.max);
    this.apply();    
},
drag: function(name, event) {
    this.dragging = {
        name: name,
        value: this.selected[name],
        x: event.pageX
    };
    $(document).on('mousemove', this.$move);
    $(document).on('mouseup', this.$drop);
    event.stopPropagation();
    event.preventDefault();
},
move: function(x) {
    var d = this.dragging;
    var offset = Math.round((x - d.x) / this.scale);
    if (offset !== d.offset) {
        var s = this.selected;
        var e = this.enabled;
        if (d.name === 'min') {
            d.value = (s.min + offset).constrain(0, Math.min(s.max, e.max) - 1);
            this.show(d.value, s.max);
        } else {
            d.value = (s.max + offset).constrain(Math.max(s.min, e.min) + 1, this.size);
            this.show(s.min, d.value);
        }        
        d.offset = offset;
    }
},
drop: function() {
    var d = this.dragging;
    if (d) {
        this.selected[d.name] = d.value;
        delete this.dragging;
        this.apply();
    }
    $(document).off('mousemove', this.$move);
    $(document).off('mouseup', this.$drop);
},
show: function(d1, d2) {
    var x1 = Math.round(d1 * this.scale);
    var x2 = Math.round(d2 * this.scale);
    this.sliders.eq(0).css('left', x1 - 4);
    this.sliders.eq(1).css('left', x2 - 4);
    var r1 = Math.round(Math.max(this.enabled.min, d1) * this.scale);
    var r2 = Math.round(Math.min(this.enabled.max, d2) * this.scale);
    this.selected.el.css({width: x2 - x1 + 1, left: x1 + 3});
    this.enabled.el.css({width: r2 - r1 + 1, left: r1 + 3});
    this.human(d1, d2);
},
toggle: function(proper) {
    var s = this.selected, min, max;
    if (proper) {
        for (var i = this.size; i--;) {
            if (proper.indexOf('ldur' + i + ' ') !== -1) {
                if (max === undefined) max = Math.min(this.size, i + 1);
                min = i;
            }
        }
    } else {
        min = 0;
        max = this.size;
    }
    this.enabled.min = min;
    this.enabled.max = max;
    this.show(s.min, s.max);
},
human: function(d1, d2) {
    var parts = [];
    var min = this.from + d1;
    var max = this.from + d2;
    if (max - min < this.size) {
        if (max < 3) {
            parts.push(lang.filters.short);
        } else if (min > 4) {
            parts.push(lang.filters.long);
        }
        parts.push(lamg.filters[min ? 'fromto' : 'less'].absorb(min, max.declineArray(lang.time.hours)));
    } else {
        parts.push(lang.filters.any);
    }
    this.value.html(parts.join(', '));
},
apply: function() {
    var conditions = [];
    var min = this.selected.min;
    var max = this.selected.max;
    if (min) {
        conditions.push('f.ldur > ' + ((this.from + min) * 60 - 1));
    }
    if (max < this.size) {
        conditions.push('f.ldur < ' + ((this.from + max) * 60 + 1));
    }
    var merged;
    if (conditions.length) {
        merged = '(' + conditions.join(' && ') + ')';
        if (!min) {
            merged = '(f.nonstop || ' + merged + ')';
        }
    }
    if (merged !== this.conditions) {
        this.conditions = merged;
    }
    this.group.apply();
    results.filters.apply();
}
};

/* One stop */
results.onestopCheckbox = {
init: function() {
    var that = this;
    this.el = $('#rf-onestop');
    this.label = this.el.parent().find('label');
    this.el.click(function() {
        that.apply();
    });
    this.key = 'onestop';
},
apply: function() {
    this.conditions = this.el.prop('checked') ? '(f.onestop || f.nonstop)' : undefined;
    this.group.apply();
    results.filters.apply();
},
toggle: function(proper) {
    var disabled = proper ? proper.indexOf('onestop') === -1 : false;
    this.label.toggleClass('rfos-disabled', disabled);
    this.el.prop('disabled', disabled);
},
reset: function() {
    this.el.prop('checked', false);
    this.conditions = undefined;
}
};
