controls = {};
controls.Filter = function(selector, options) {
    this.el = $(selector);
    this.init(options);
    return this;
};
controls.Filter.prototype = {
init: function(options) {
    var self = this;
    this.values = $('.values', this.el).delegate('.value', 'click', function() {
        var el = $(this);
        if (self.options.preserve) {
            self.show();
        } else {
            delete(self.selected[el.attr('data-value')]);
            el.fadeTo(200, 0.5, function() {
                self.update();
            });
        }
    });
    if (options && options.preserve) {
        this.values.addClass('preserved');
    }
    this.dropdown = $('.dropdown', this.el).click(function(event) {
        event.stopPropagation();
    }).delegate('dd', 'click', function() {
        self.click($(this));
    });
    $('.control', this.el).click(function() {
        self.show();
    });
    this.selfhide = function(event) {
        if (event.type == 'click' || event.which == 27) self.hide();
    };
    this.selected = {};
    this.empty = $('dd.empty', this.dropdown);
    this.items = $('dd:not(.empty)', this.dropdown);    
    this.options = options || {};
    this.value = [];
},
fill: function(items) {
    var template = '<dd data-value="{v}">{t}</dd>';
    var list = $('dl', this.dropdown);
    this.items && this.items.remove();
    if (items) for (var i = 0, im = items.length; i < im; i++) {
        list.append(template.supplant(items[i]));
    }
    this.items = $('dd:not(.empty)', list);
    this.reset();
},
click: function(el) {
    if (el.hasClass('empty')) {
        this.selected = {};
    } else {
        var value = el.attr('data-value');
        if (this.selected[value]) {
            delete(this.selected[value]);
        } else {
            if (this.options.radio) this.selected = {};
            this.selected[value] = true;
        }
    }
    this.update();
    this.hide();
},
select: function(values) {
    this.selected = {};
    for (var i = values.length; i--;) this.selected[values[i]] = true;
    this.update();
},
reset: function() {
    this.selected = {};
    this.update();    
},
update: function() {
    var self = this;
    var result = [], values = [];
    var template = '<span class="value" data-value="{value}">{title}</span>';
    this.items.each(function() {
        var item = $(this);
        var value = item.attr('data-value');
        if (self.selected[value]) {
            item.addClass('selected');
            result.push(template.supplant({
                value: value,
                title: item.text()
            }));
            values.push(value);
        } else {
            item.removeClass('selected');
        }
    });
    this.empty.toggleClass('selected', result.length == 0);    
    if (result.length == this.items.length) {
        values = result = [];
    }
    if (result.length) {
        this.values.html(' (' + result.enumeration(' или ') + ')').show();
    } else {
        this.values.html('').hide();
    }
    this.value = values;
    this.el.trigger('change', [values]);
},
show: function() {
    var d = this.dropdown, w = $(window), self = this;
    d.css('visibility', 'hidden').show();
    var coffset = this.el.closest('.filters').offset();
    var foffset = this.el.find('.control em').offset();
    d.hide().css({
        'top': Math.min(foffset.top, w.height() + w.scrollTop() - d.height() - 5) - coffset.top,
        'left': foffset.left - coffset.left,
        'visibility': 'inherit'
    });
    setTimeout(function() {
        $(window).bind('click keydown', self.selfhide);
    }, 30);
    this.dropdown.fadeIn(200);
},
hide: function() {
    $(window).unbind('click keydown', this.selfhide);
    this.dropdown.fadeOut(150);
}
};