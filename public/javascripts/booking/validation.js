var validator = {
control: function(el, messages) {
    var that = this;
    this.el = el;
    this.messages = messages;
    this.selfvalidate = function() {
        that.validate()
    };
    this.important = {};
    return this;
},
text: function(el, messages) {
    var item = new this.control(el, messages);
    el.change(function() {
        el.val($.trim(el.val()));
        item.validate();
    }).bind('keyup propertychange input', function() {
        item.change();
    });
    return item;
},
name: function(el, messages) {
    var item = new this.control(el, messages);
    item.important = {
        latin: true,
        space: true
    };
    item.check = function() {
        var value = $.trim(this.el.val());
        if (!value) {
            return 'empty';
        }
        if (value.search(/[^a-z ]/i) !== -1) {
            return 'latin';
        }
        if (messages.space && value.search(/ /) !== -1) {
            return 'space';
        }
        if (messages.short && value.length < 2) {
            return 'short';
        }
        return undefined;
    };
    el.change(function() {
        el.val($.trim(el.val().toUpperCase()));
        item.validate();
    }).bind('keyup propertychange input', function() {
        item.change();
    });
    return item;
},
gender: function(radio, messages) {
    var item = new this.control(radio, messages);
    var m = radio.get(0);
    var f = radio.get(1);
    item.invalid = radio.eq(0).closest('.bp-sex');
    item.check = function() {
        return (m.checked || f.checked) ? undefined : 'empty';
    };
    radio.click(function() {
        $(this).closest('.bp-sex').find('.selected').removeClass('selected');
        $(this).closest('label').addClass('selected');
        item.validate();
    }).focus(function() {
        $(this).closest('label').addClass('focus');
    }).blur(function() {
        $(this).closest('label').removeClass('focus');
    });
    return item;
},
number: function(el, messages) {
    var item = new this.control(el, messages);
    item.important = {
        latin: true
    };
    item.check = function() {
        var value = this.el.val();
        if (!value) {
            return 'empty';
        }
        if (value.search(/[а-яё]/i) !== -1) {
            return 'latin';
        }
        return undefined;
    };
    el.change(function() {
        el.val($.trim(el.val().toUpperCase()));
        item.validate();
    }).bind('keyup propertychange input', function() {
        item.change();
    });
    return item;
},
date: function(parts, messages) {
    var item = new this.control(parts, messages);
    var today = new Date();
    item.check = function() {
        var values = [];
        for (var i = 0; i < 3; i++) {
            var f = parts.eq(i), v = f.val();
            this.invalid = f;
            if (v.length === 0) return 'empty';
            if (v.search(/[^\d]/) !== -1) return 'letters';
            values[i] = parseInt(v, 10);
        }
        if (values[2] < 1000) {
            return 'shortyear';
        }
        var parsed = new Date(values[2], values[1] - 1, values[0], 12);
        if (parsed.getDate() !== values[0] || parsed.getMonth() + 1 !== values[1] || parsed.getFullYear() !== values[2]) {
            return 'unreal';
        }
        if (messages.future && parsed.getTime() > today.getTime()) {
            return 'future';
        }
        if (messages.past && parsed.getTime() < today.getTime()) {
            return 'past';
        }
        return undefined;
    };
    item.important = {
        letters: true,
        future: true,
        past: true,
        unreal: true
    };
    parts.focus(function() {
        $(this).prev('.placeholder').hide();
        ignoreTab = true;
    }).blur(function() {
        var f = $(this);
        f.prev('.placeholder').toggle(f.val().length === 0);
    }).bind('keyup propertychange input', function() {
        item.change();
    });
    var ignoreTab = false;
    parts.slice(0, 2).change(function() {
        var f = $(this), v = f.val();
        if (v && v.length < 2 && v.search(/\D/) === -1) f.val('0' + v);
        item.validate();
    }).keypress(function(e) {
        if (this.value && String.fromCharCode(e.which).search(/[ .,\-\/]/) === 0) {
            $(this).change().parent().next().find('input').focus();
            e.preventDefault();
        }
    }).keyup(function(e) {
        var code = e.which;
        var digit = (code > 47 && code < 58) || (code > 95 && code < 106);
        if (this.value.length === 2 && digit) {
            $(this).change().parent().next().find('input').focus();
            ignoreTab = true;
        }
    });
    parts.slice(1).keydown(function(e) {
        if (e.which === 8 && this.value.length === 0) {
            $(this).blur().change().parent().prev().find('input').focus();
        } else if (ignoreTab && e.which === 9 && !e.shiftKey) {
            e.preventDefault();
        }
        ignoreTab = false;
    });
    parts.eq(2).change(function() {
        var f = $(this), v = f.val();
        if (v && v.length < 4 && v.search(/\D/) === -1) {
            var y = parseInt(f.val(), 10);
            if (messages.past && y < 100) y += 2000;
            if (y <= today.getFullYear() % 100) y += 2000;
            if (y < 1000) y = 1900 + y % 100;
            f.val(y);
        }
        item.validate();
    });
    return item;
},
email: function(el, messages) {
    var item = new this.control(el, messages);
    var mask = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i;
    item.check = function() {
        var value = $.trim(this.el.val());
        if (value.length < 5 || value.indexOf('@') < 0 || value.indexOf('.') < 0 || value.indexOf('.') === value.length - 1) {
            return 'empty';
        }
        if (!mask.test(value)) {
            return 'wrong';
        }
        return undefined;
    };
    el.change(function() {
        el.val($.trim(el.val()));
        item.validate();
    }).bind('keyup propertychange input', function() {
        item.change();
    });
    return item;
},
phone: function(el, messages) {
    var item = new this.control(el, messages);
    item.important = {
        letters: true
    };
    item.check = function() {
        var value = this.el.val();
        if (!value) {
            return 'empty';
        }
        if (value.search(/[^\d() \-+]/i) !== -1) {
            return 'letters';
        }
        var digits = value.replace(/\D/g, '');
        if (digits.length < 7) {
            return 'short';
        }
        return undefined;
    };
    el.change(function() {
        var v = $.trim(el.val());
        v = v.replace(/(\d)\(/, '$1 (');
        v = v.replace(/\)(\d)/, ') $1');
        v = v.replace(/(\D)(\d{2,3})(\d{2})(\d{2})$/, '$1$2-$3-$4');
        el.val(v);
        item.validate();
    }).bind('keyup propertychange input', function() {
        item.change();
    });
    return item;
},
cardnumber: function(parts, messages) {
    var item = new this.control(parts, messages);
    item.important = {
        letters: true
    };
    item.check = function() {
        for (var i = 0; i < 4; i++) {
            var f = parts.eq(i), v = f.val();
            this.invalid = f;
            if (v.length === 0) return 'empty';
            if (v.search(/[^\d]/) !== -1) return 'letters';
            if (v.length < 4) return 'empty';
        }
        return undefined;
    };
    parts.bind('paste', function() {
        var field = $(this);
        var el = $(this).attr('maxlength', 50);
        setTimeout(function() {
            var v = el.val().replace(/\D/g, '');
            while (el.length && v.length) {
                el.val(v.substring(0, 4));
                if (v.length > 3) {
                    el = el.next('input');
                    v = v.substring(4);
                } else {
                    break;
                }
            }
            el.focus();
            field.attr('maxlength', 4);
        }, 10);
    }).focus(function() {
        ignoreTab = true;
    });
    var ignoreTab = false;
    parts.slice(0, 3).keyup(function(e) {
        var code = e.which;
        var digit = (code > 47 && code < 58) || (code > 95 && code < 106);
        if (this.value.length === 4 && digit) {
            $(this).trigger('change').next('input').select();
            ignoreTab = true;
        }
    });
    parts.slice(1).keydown(function(e) {
        if (this.value.length === 0 && e.which === 8) {
            $(this).trigger('change').prev('input').focus();
        } else if (ignoreTab && e.which === 9 && !e.shiftKey) {
            e.preventDefault();
        }
        ignoreTab = false;
    });
    parts.bind('keyup propertychange input', function() {
        item.change();
    });
    return item;
},
cardexp: function(parts, messages) {
    var item = new this.control(parts, messages);
    var mf = parts.eq(0);
    var yf = parts.eq(1);
    var today = new Date();
    item.important = {
        month: true,
        past: true,
        letters: true
    };
    item.check = function() {
        var mv = mf.val();
        var yv = yf.val();
        this.invalid = mf;
        if (mv.length === 0) {
            return 'empty';
        }
        if (mv.search(/\D/) !== -1) {
            return 'letters';
        }
        var m = parseInt(mv, 10);
        if (m < 1 || m > 12) {
            return 'month';
        }
        if (yv.length < 2) {
            this.invalid = yf;
            return 'empty';
        }
        if (yv.search(/\D/) !== -1) {
            this.invalid = yf;
            return 'letters';
        }
        var y = parseInt(yv, 10);
        if (y * 12 + m < today.getFullYear() % 100 * 12 + today.getMonth() + 1) {
            return 'past';
        }
        return undefined;
    };
    var ignoreTab = false;
    mf.change(function() {
        var f = $(this), v = f.val();
        if (v && v.length < 2) f.val('0' + v);
    }).keypress(function(e) {
        if (this.value && String.fromCharCode(e.which).search(/[ .,\-\/]/) === 0) {
            e.preventDefault();
            mf.change();
            yf.focus();
        }
    }).keyup(function(e) {
        var code = e.which;
        var digit = (code > 47 && code < 58) || (code > 95 && code < 106);
        if (this.value.length === 2 && digit) {
            mf.change();
            yf.focus();
            ignoreTab = true;
        }
    });
    yf.slice(1).keydown(function(e) {
        if (e.which === 8 && this.value.length === 0) {
            yf.change();
            mf.focus();
        } else if (ignoreTab && e.which === 9 && !e.shiftKey) {
            e.preventDefault();
        }
        ignoreTab = false;
    });
    parts.focus(function() {
        $(this).prev('.placeholder').hide();
        ignoreTab = false;
    }).blur(function() {
        var f = $(this);
        f.prev('.placeholder').toggle(f.val().length === 0);
    }).bind('keyup propertychange input', function() {
        item.change();
    }).change(function() {
        item.validate();
    });
    return item;
},
cardcvv: function(el, messages) {
    var item = new this.control(el, messages);
    item.important = {
        letters: true,
    };
    item.check = function() {
        var value = this.el.val();
        if (value.length < 3) {
            return 'empty';
        }
        if (value.search(/\D/) !== -1) {
            return 'letters';
        }
        return undefined;
    };
    el.change(function() {
        item.validate();
    }).bind('keyup propertychange input', function() {
        item.change();
    });
    return item;
}
};

validator.control.prototype = {
validate: function() {
    clearTimeout(this.vtimer);
    var error = this.disabled ? undefined : this.check();
    if (error !== this.error || this.invalid) {
        if (error) {
            var message = this.messages[error], el = this.invalid || this.el;
            message = message.replace('{', '<span class="link" data-field="' + el.attr('id') + '">');
            message = message.replace('}', '</span>');
            this.message = message;
        } else {
            this.message = undefined;
        }
        this.error = error;
        this.update();
        this.onchange();
    }
},
change: function() {
    clearTimeout(this.vtimer);
    this.vtimer = setTimeout(this.selfvalidate, 200);
},
update: function() {
    var e = this.error;
    this.el.toggleClass('valid', e === undefined);
    this.el.toggleClass('invalid', Boolean(e && this.important[e]));
},
check: function() {
    var v = this.el.val();
    return v.length ? undefined : 'empty';
},
onchange: function() {
    booking.form.validate();
}
};
