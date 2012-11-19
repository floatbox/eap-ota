/* Controls namespace */
var validator = {
update: function(error) {
    if (error === this.error) return false;
    this.el.toggleClass('bf-error', error !== undefined && error !== 'empty' && error !== 'short');
    this.el.toggleClass('bf-valid', error === undefined);
    if (this.error = error) {
        this.message = this.messages[error].replace('{', '<span class="bffr-link" data-field="' + this.fid + '">').replace('}', '</span>');
    } else {
        delete this.message;
    }
    return true;
},
getGender: function(name) {
    var sample = ' ' + name.toLowerCase() + ',';
    if (this.names.m.contains(sample)) return 'm';
    if (this.names.f.contains(sample)) return 'f';
}
};

/* Section */
validator.Section = function(el, options) {
    this.el = el;
    $.extend(this, options);
    this.controls = [];
    this.empty = [];
    this.wrong = [];
    this.init();
};
validator.Section.prototype = {
init: function() {
    return;
},
bind: function(apply) {
    for (var i = this.controls.length; i--;) {
        this.controls[i].apply = apply;
    }
},
validate: function(forced) {
    this.wrong = [];
    this.empty = [];
    for (var i = 0, l = this.controls.length; i < l; i++) {
        var control = this.controls[i];
        if (forced && control.validate) {
            control.validate();
        }
        if (control.error && !control.disabled && control.message) {
            this[control.error === 'empty' ? 'empty' : 'wrong'].push(control.message);
        }
    }
    this.toggle(this.wrong.length + this.empty.length === 0);
},
toggle: function(ready) {
    this.el.toggleClass('bfs-ready', ready);
},
set: function(data) {
    for (var i = 0, l = this.controls.length; i < l; i++) {
        if (data[i] !== undefined) this.controls[i].set(data[i]);
    }
},
get: function() {
    var data = [];
    for (var i = 0, l = this.controls.length; i < l; i++) {
        var control = this.controls[i];
        data[i] = control.get ? control.get() : '';
    }
    return data;
}
};

/* Text control */
validator.Text = function(el, messages, check) {
    this.el = el;
    this.messages = messages;
    this.update = validator.update;
    this.check = check || $.noop;
    this.error = null;
    this.init();
};
validator.Text.prototype = {
init: function() {
    var that = this;
    this.el.bind('keyup propertychange input paste', function() {
        that.change();
    }).focus(function() {
        that.el.addClass('bf-focus');
    }).blur(function() {
        that.el.removeClass('bf-focus');
    }).change(function() {
        var ov = that.el.val();
        var nv = that.format(ov);
        that.el.val(nv);
    });
    this.fid = this.el.attr('id');
    this.$validate = function() {
        that.validate(true);
    };
    var placeholder = this.el.prev('.bf-placeholder');
    if (placeholder.length) {
        placeholder.toggle(!this.el.val());
        this.placeholder = placeholder;
    }
},
change: function() {
    clearTimeout(this.timer);
    this.timer = setTimeout(this.$validate, 150);
    if (this.placeholder) {
        this.placeholder.toggle(!this.el.val());
    }
},
validate: function(self) {
    clearTimeout(this.timer);
    var value = $.trim(this.el.val());
    var error = value ? this.check(value) : 'empty';
    if (this.update(error) && self) {
        this.apply();
    }
},
apply: function() {
    booking.form.validate();
},
format: function(value) {
    return $.trim(value);
},
set: function(value) {
    this.el.val(this.format(value || '')).trigger('input');
    this.validate();
},
get: function() {
    return this.el.val();
}
};

/* Select control */
validator.Select = function(el) {
    this.el = el;
    this.disabled = true;
    this.init();
};
validator.Select.prototype = {
init: function() {
    var that = this;
    var field = this.el.find('input').addClass('bf-valid');
    var value = field.val();
    field.val('');
    this.select = this.el.find('select');
    if (value) {
        this.select.val(value);
    }
    this.select.focus(function() {
        field.addClass('bf-focus');
    }).blur(function() {
        field.removeClass('bf-focus');
    }).bind('change keyup click', function() {
        var title = this.options[this.selectedIndex].text;
        that.el.attr('title', title);
        field.val(title);
    }).change();
},
validate: function() {
    delete this.error;
},
set: function(value) {
    if (value) {
        this.select.val(value).trigger('change');
    } else {
        this.select.get(0).selectedIndex = 0;
    }
},
get: function() {
    return this.select.val();
}
};

/* Checkbox control */
validator.Checkbox = function(el) {
    this.el = el;
    this.disabled = true;
};
validator.Checkbox.prototype = {
set: function(value) {
    this.el.prop('checked', Boolean(value)).trigger('set');
},
get: function() {
    return this.el.prop('checked') ? 'true' : '';
}
};

/* Date control */
validator.Date = function(el, messages, check) {
    this.el = el;
    this.messages = messages;
    this.update = validator.update;
    this.check = check || $.noop;
    this.error = null;
    this.year = search.dates.csnow.getFullYear() % 100;
    this.time = search.dates.csnow.getTime();
    this.init();
};
validator.Date.prototype = {
init: function() {
    var that = this;
    this.parts = this.el.find('input');
    this.parts.bind('keyup propertychange input', function() {
        var f = $(this);
        that.change();
        f.prev('label').toggle(!f.val());
    }).focus(function() {
        that.el.addClass('bf-focus');
    }).blur(function() {
        var f = $(this);
        that.el.removeClass('bf-focus');
        f.prev('label').toggle(!f.val());
    });
    this.$validate = function() {
        that.validate(true);
    };
    this.parts.each(function() {
        var f = $(this);
        f.prev('label').toggle(!f.val());
    });
    this.ctime = ((search && search.dates && search.dates.csnow) ||  new Date()).getTime();
    this.initParts();
    this.initFormat();
    if (!browser.ios) {
	    this.initTab();
	}
},
initParts: function() {
    this.dpart = this.parts.eq(0);
    this.dfid = this.dpart.attr('id');
    this.mpart = this.parts.eq(1);
    this.mfid = this.mpart.attr('id');
    this.ypart = this.parts.eq(2);
    this.yfid = this.ypart.attr('id');
    this.fid = this.dfid;
},
initFormat: function() {
    var that = this;
    this.parts.slice(0, 2).change(function() {
        var field = $(this), value = $.trim(field.val());
        if (value && value.search(/^[1-9]$/) === 0) {
            field.val('0' + value);
            that.validate();
        }
    });
    this.ypart.change(function() {
        var field = $(this), value = $.trim(field.val());
        if (value && value.search(/^\d{1,3}$/) === 0) {
            var y = parseInt(value, 10);
            if ((that.future && y < 100) || y <= that.cyear) {
                y += 2000;
            } else if (y < 1000) {
                y = 1900 + y % 100;
            }
            field.val(y);
            that.validate(true);
        }
    });
},
initTab: function() {
    var that = this, spacers = '., -/', ignoreTab;
    this.dpart.data('next', this.mpart);
    this.mpart.data('prev', this.dpart);
    this.mpart.data('next', this.ypart);
    this.ypart.data('prev', this.mpart);
    this.parts.keypress(function(e) {
        ignoreTab = false;
        if (spacers.indexOf(String.fromCharCode(e.which)) !== -1) {
            e.preventDefault();
            var field = $(this), next = field.data('next');
            if (this.value && next) {
                field.change();
                next.select();
            }
        }
    });
    this.parts.slice(0, 2).keyup(function(e) {
        var code = e.which;
        var digit = (code > 47 && code < 58) || (code > 95 && code < 106);
        if (this.value.length === 2 && digit && !ignoreTab) {
            $(this).change().data('next').focus().select();
            that.el.addClass('bf-focus');
            ignoreTab = true;
        }
    });
    this.parts.slice(1).keydown(function(e) {
        if (e.which === 8 && this.value.length === 0) {
            $(this).blur().change().data('prev').focus();
        } else if (ignoreTab && e.which === 9 && !e.shiftKey) {
            e.preventDefault();
        }
    });
},
change: function() {
    clearTimeout(this.timer);
    this.timer = setTimeout(this.$validate, 150);
},
validate: function(self) {
    clearTimeout(this.timer);
    var value = this.parse(this.dpart.val(), this.mpart.val(), this.ypart.val());
    var error = typeof value === 'string' ? value : this.check(value);
    this.el.trigger('validate', [error === undefined ? value : undefined]);
    if (this.update(error) && self) {
        this.apply();
    }
},
apply: function() {
    booking.form.validate();
},
parse: function(d, m, y) {
    var dn, mn, yn, digits = /\D/;
    if (d) {
        this.fid = this.dfid;
        if (digits.test(d)) return 'letters';
        if (d === '00' || (dn = parseInt(d, 10)) > 31) return 'wrong';
    }
    if (m) {
        this.fid = this.mfid;
        if (digits.test(m)) return 'letters';
        if (m === '00' || (mn = parseInt(m, 10)) > 12) return 'wrong';
    }
    if (y) {
        this.fid = this.yfid;
        if (digits.test(y)) return 'letters';
        yn = parseInt(y, 10);
    }
    if (!dn) {
        this.fid = this.dfid;
        return 'empty';
    }
    if (!mn) {
        this.fid = this.mfid;
        return 'empty';
    }
    if (y.length < 4) {
        this.fid = this.yfid;
        return 'empty';
    }
    var date = new Date(yn, mn - 1, dn, 12);
    if (date.getDate() !== dn || date.getMonth() !== mn - 1 || date.getFullYear() !== yn) {
        this.fid = this.dfid;
        return 'wrong';
    }
    return date;
},
set: function(value) {
    var vparts = value ? value.split('.') : [];
    this.parts.val(function(i) {
        return vparts[i] || '';
    }).trigger('input');
    this.validate();
},
get: function() {
    if (this.error) return '';
    var parts = [];
    this.parts.each(function(i) {
        parts[i] = $(this).val();
    });
    return parts.join('.');
}
};

/* Gender control */
validator.Gender = function(el) {
    this.el = el;
    this.init();
};
validator.Gender.prototype = {
init: function() {
    var that = this;
    this.checkboxes = this.el.find('input');
    this.checkboxes.focus(function() {
        $(this).parent().addClass('bfp-sex-hover');
        that.el.addClass('bf-focus');
    }).blur(function() {
        $(this).parent().removeClass('bfp-sex-hover');
        that.el.removeClass('bf-focus');
    }).bind('click set', function(event) {
        $(this).parent().addClass('bfp-sex-selected').siblings().removeClass('bfp-sex-selected');
        that.change(true);
        if (event.type !== 'set') {
            that.apply();
        }
    });
    this.el.find('label').mousedown(function() {
        var input = $(this).find('input');
        setTimeout(function() {
            input.focus();
        }, 10);
    });
    this.fid = this.el.attr('id');
    this.change(false);
},
set: function(value) {
    this.checkboxes.prop('checked', false);
    this.el.find('bfp-sex-selected').removeClass('bfp-sex-selected');
    if (value) {
        this.el.find('.bfp-sex-' + value + ' input').prop('checked', true).trigger('set');
    }
    this.change(Boolean(value));
},
get: function() {
    return this.el.find('input:checked').val() || '';
},
change: function(checked) {
    if (checked) {
        delete this.message;
        delete this.error;
    } else {
        this.message = '<span class="bffr-link" data-field="' + this.fid + '">пол пассажира</span>';
        this.error = 'empty';
    }
},
validate: function() {
    return;
},
apply: function() {
    booking.form.validate();
}
};

/* Card number control */
validator.CardNumber = function(el, messages) {
    this.el = el;
    this.messages = messages;
    this.update = validator.update;
    this.error = null;
    this.init();
};
validator.CardNumber.prototype = {
init: function() {
    var that = this;
    this.parts = this.el.find('input');
    this.parts.bind('keyup propertychange input', function() {
        that.change();
    }).focus(function() {
        that.el.addClass('bf-focus');
    }).blur(function() {
        that.el.removeClass('bf-focus');
    }).bind('paste', function() {
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
            that.change();
        }, 10);
    });
    this.$validate = function() {
        that.validate(true);
    };
    this.fid = 'bfcn-part1';
    if (!browser.ios) {
	    this.initAutoTab();
    }
},
initAutoTab: function() {
    var that = this, ignoreTab;
    this.parts.slice(0, 3).keyup(function(e) {
        var code = e.which;
        var digit = (code > 47 && code < 58) || (code > 95 && code < 106);
        if (this.value.length === 4 && digit && !ignoreTab) {
            $(this).change().next().select();
            that.el.addClass('bf-focus');
            ignoreTab = true;
        }
    });
    var spacers = '., -/';
    this.parts.keypress(function(e) {
        ignoreTab = false;
        if (spacers.indexOf(String.fromCharCode(e.which)) !== -1) {
            e.preventDefault();
        }
    });
    this.parts.slice(1).keydown(function(e) {
        if (e.which === 8 && this.value.length === 0) {
            $(this).blur().change().prev().focus();
        } else if (ignoreTab && e.which === 9 && !e.shiftKey) {
            e.preventDefault();
        }
    });
},
change: function() {
    clearTimeout(this.timer);
    this.timer = setTimeout(this.$validate, 150);
},
validate: function(self) {
    clearTimeout(this.timer);
    var values = [];
    for (var i = 4; i--;) {
        values[i] = this.parts.eq(i).val();
    }
    var error = this.check(values);
    if (this.update(error) && self) {
        this.apply();
    }
},
check: function(values) {
    for (var i = 0; i < 4; i++) {
        var s = values[i];
        this.fid = 'bfcn-part' + (i + 1);
        if (/\D/.test(s)) return 'letters';
        if (s.length < 4) return 'empty';
    }
    var s = values.join(''), sum = 0;
    if (/41{14}|70{14}|5486732058864471|1234561999999999/.test(s)) {
        return; // тестовые карты
    }
    for (var i = 0; i < 16; i += 2) {
        var n1 = Number(s.charAt(i)) * 2;
        var n2 = Number(s.charAt(i + 1));
        if (n1 > 9) n1 -= 9;
        sum += n1 + n2;
    }
    if (sum % 10 !== 0) {
        return 'wrong';
    }
},
apply: function() {
    booking.form.validate();
}
};

/* Card date control */
validator.CardDate = function(el, messages) {
    this.el = el;
    this.messages = messages;
    this.update = validator.update;
    this.error = null;
    var dmy = search.dates.csnow.DMY();
    this.time = dmy.substring(4, 6) + dmy.substring(2, 4);
    this.init();
};
validator.CardDate.prototype = {
init: function() {
    var that = this;
    this.parts = this.el.find('input');
    this.parts.bind('keyup propertychange input', function() {
        that.change();
    }).focus(function() {
        that.el.addClass('bf-focus');
    }).blur(function() {
        that.el.removeClass('bf-focus');
    });
    this.$validate = function() {
        that.validate(true);
    };
    this.initFormat();
    if (!browser.ios) {    
	    this.initAutoTab();
    }
},
initFormat: function() {
    var that = this;
    this.parts.first().change(function() {
        var field = $(this), value = $.trim(field.val());
        if (value && value.search(/^[1-9]$/) === 0) {
            field.val('0' + value);
            that.validate();
        }
    });
},
initAutoTab: function() {
    var that = this, ignoreTab;
    var spacers = '., -/';
    this.parts.first().keyup(function(e) {
        var code = e.which;
        var digit = (code > 47 && code < 58) || (code > 95 && code < 106);
        if (this.value.length === 2 && digit && !ignoreTab) {
            that.parts.eq(0).change();
            that.parts.eq(1).select();
            that.el.addClass('bf-focus');
            ignoreTab = true;
        }
    }).keypress(function(e) {
        ignoreTab = false;
        if (spacers.indexOf(String.fromCharCode(e.which)) !== -1) {
            e.preventDefault();
            if (this.value) {
                that.parts.eq(0).change();
                that.parts.eq(1).select();
            }
        }
    });
    this.parts.eq(1).keypress(function(e) {
        ignoreTab = false;
        if (spacers.indexOf(String.fromCharCode(e.which)) !== -1) {
            e.preventDefault();
        }
    }).keydown(function(e) {
        if (e.which === 8 && this.value.length === 0) {
            that.parts.eq(1).blur().change();
            that.parts.eq(0).focus();
        } else if (ignoreTab && e.which === 9 && !e.shiftKey) {
            e.preventDefault();
        }
    });
},
change: function() {
    clearTimeout(this.timer);
    this.timer = setTimeout(this.$validate, 150);
},
validate: function(self) {
    clearTimeout(this.timer);
    var m = $.trim(this.parts.eq(0).val());
    var y = $.trim(this.parts.eq(1).val());
    var error = this.check(m, y);
    if (this.update(error) && self) {
        this.apply();
    }
},
apply: function() {
    booking.form.validate();
},
check: function(m, y) {
    this.fid = 'bc-exp-month';
    if (!m || m === '0') return 'empty';
    if (/\D/.test(m)) return 'letters';
    if (Number(m) > 12) return 'wrong';
    this.fid = 'bc-exp-year';
    if (/\D/.test(y)) return 'letters';
    if (y.length < 2) return 'empty';
    if (y + m < this.time) return 'improper';
},
set: function(value) {
    var vparts = value ? value.split('.') : [];
    this.parts.val(function(i) {
        return vparts[i] || '';
    });
    this.validate();
}
};
