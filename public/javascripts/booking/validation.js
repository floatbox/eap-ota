app.booking.validate = function(full) {
    clearTimeout(this.vtimer);
    var errors = [];
    for (var s = 0, sm = this.sections.length; s < sm; s++) {
        var valid = true;
        var section = this.sections[s];
        for (var i = 0, im = section.items.length; i < im; i++) {
            var item = section.items[i];
            if (full) {
                item.validate();
            }
            if (item.message) {
                errors.push(item.message);
                valid = false;
            }
        }
        section.el.toggleClass('ready', valid);
    }
    if (errors.length) {
        this.el.find('.b-pseudo').html('<li>' + errors.slice(0, 3).join('</li><li>') + '</li>');
    } else {
        this.el.find('.b-pseudo').html('');
    }
};

app.booking.initPerson = function(el) {
    var fname = validator.name(el.find('input[id$="first_name"]'), {
        empty: 'Не указано {имя пассажира}',
        short: '{Имя пассажира} нужно ввести полностью',
        latin: '{Имя пассажира} нужно ввести латинскими буквами'
    });
    var lname = validator.name(el.find('input[id$="last_name"]'), {
        empty: 'Не указана {фамилия пассажира}',
        short: '{Фамилию пассажира} нужно ввести полностью',
        latin: '{Фамилию пассажира} нужно ввести латинскими буквами'
    });
    var gender = validator.gender(el.find('.bp-sex-radio'), {
        empty: 'Не выбран {пол пассажира}'
    });
    var getGender = function(name) {
        var pattern = ' ' + name.toLowerCase() + ',';
        if (constants.names['m'].indexOf(pattern) !== -1) return 'm';
        if (constants.names['f'].indexOf(pattern) !== -1) return 'f';
        return undefined;
    };
    fname.el.change(function() {
        var selected = gender.el.filter(':checked');
        if (selected.length === 0) {
            var auto = getGender($(this).val().toLowerCase());
            var radio = auto && gender.el.filter('[value="' + auto + '"]');
            if (radio) {
                radio.get(0).checked = true;
                radio.click();
                gender.validate();
            }
        }
    });
    var bdate = validator.date(el.find('.bp-birthday input'), {
        empty: 'Не указана {дата рождения} пассажира',
        letters: '{Дату рождения} нужно ввести цифрами в формате дд/мм/гггг',
        incomplete: '{Дата рождения} не введена полностью',
        shortyear: '{Год рождения} нужно ввести полностью',
        unreal: 'Указана несуществующая {дата рождения}',
        future: '{Дата рождения} не может быть позднее сегодняшней'
    });
    var passport = validator.number(el.find('input[id$="passport"]'), {
        empty: 'Не указан {номер документа}',
        latin: 'В {номере документа} можно использовать только латинские буквы'
    });
    var pdate = validator.date(el.find('.bp-docexp .date-item input'), {
        empty: 'Не указан {срок действия} документа',
        letters: '{Срок действия} документа нужно ввести цифрами в формате дд/мм/гггг',
        incomplete: '{Срок действия} документа не введен полностью',
        shortyear: 'Год в {сроке действия} документа нужно ввести полностью',
        unreal: 'Указана несуществующая дата в {сроке действия} документа',
        past: 'Указан истекший {срок действия} документа'
    });
    el.find('.bp-docexp input:checkbox').click(function() {
        pdate.disabled = $(this).get(0).checked;
        $(this).closest('td').toggleClass('disabled', pdate.disabled);
        pdate.el.each(function() {
            this.disabled = pdate.disabled;
        });
        pdate.validate();
    });
    var bonus = validator.number(el.find('input[id^="bonus-num"]'), {
        empty: 'Не указан {номер бонусной карты}',
        latin: 'В {номере бонусной карты} можно использовать только латинские буквы'
    });
    var toggleBonus = function(mode) {
        var items = el.find('.bp-bonus');
        items.css('visibility', mode ? 'inherit': 'hidden');
        items.eq(0).find('select').get(0).disabled = !mode;
        items.eq(1).find('input').get(0).disabled = !mode;
        bonus.disabled = !mode;
    };
    toggleBonus(el.find('input:checkbox[id^="bonus"]').click(function() {
        toggleBonus(this.checked);
        if (!bonus.disabled) {
            bonus.el.focus();
        }
        bonus.validate();
        
    }).get(0).checked);
    this.sections.push({
        el: el,
        items: [fname, lname, gender, bdate, passport, pdate, bonus]
    });
};

app.booking.initCard = function(el) {
    var cardnumber = validator.cardnumber(el.find('.bcn-fields input'), {
        empty: 'Не указан {номер банковской карты}',
        letters: 'В {номере банковской карты} можно использовать только цифры'
    });
    var numsample = $('#bc-num-sample');
    cardnumber.el.last().bind('keyup change', function() {
        var v = $(this).val(), s = [], digits = /\d/;
        for (var i = 0; i < 4; i++) {
            var c = v.charAt(i);
            s[i] = digits.test(c) ? c : '<span class="empty">#</span>';
        }
        numsample.html(s.join(''));
    });
    this.sections.push({
        el: el,
        items: [cardnumber]
    });
};

app.booking.initContacts = function(el) {
    var email = validator.email(el.find('input[id$=email]'), {
        empty: 'Не указан {адрес электронной почты}',
        wrong: 'Неправильно введен {адрес электронной почты}'
    });
    var phone = validator.phone(el.find('input[id$=phone]'), {
        empty: 'Не указан {номер телефона}',
        letters: 'В {номере телефона} можно использовать только цифры',
        short: 'В {номере телефона} должно быть больше цифр (не забудьте ввести код города)'
    });
    this.sections.push({
        el: el,
        items: [email, phone]
    });
};

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
name: function(el, messages) {
    var item = new this.control(el, messages);
    item.important = {
        latin: true
    };
    item.check = function() {
        var value = $.trim(this.el.val());
        if (!value) {
            return 'empty';
        }
        if (value.search(/[^a-z]/i) !== -1) {
            return 'latin';
        }
        if (value.length < 2) {
            return 'short';
        }
        return undefined;
    };
    el.change(function() {
        el.val($.trim(el.val().toUpperCase()));
        item.validate();
    });
    el.keyup(function() {
        item.change();
    });
    return item;
},
gender: function(radio, messages) {
    var item = new this.control(radio, messages);
    var m = radio.get(0);
    var f = radio.get(1);
    item.invalid = radio.eq(0).parent();
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
    });
    el.keyup(function() {
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
    }).blur(function() {
        var f = $(this);
        f.prev('.placeholder').toggle(f.val().length === 0);
    }).keyup(function() {
        item.change();
    });
    parts.slice(0, 2).change(function() {
        var f = $(this), v = f.val();
        if (v && v.length < 2) f.val('0' + v);
        item.validate();
    }).keypress(function(e) {
        if (String.fromCharCode(e.which).search(/[ .,\-\/]/) === 0) {
            e.preventDefault();
            $(this).parent().next().find('input').focus();
        }
    });
    parts.eq(2).change(function() {
        var f = $(this), y = parseInt(f.val(), 10);
        if (messages.past && y < 100) y += 2000;
        if (y <= today.getFullYear() % 100) y += 2000;
        if (y < 1000) y = 1900 + y % 100;
        f.val(y);
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
    });
    el.keyup(function() {
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
    });
    el.keyup(function() {
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
    });
    var throwFocus = false;
    parts.slice(0, 3).keydown(function(e) {
        var code = e.which;
        var digit = (code > 47 && code < 58) || (code > 95 && code < 106);
        var space = (code === 32);
        if (throwFocus && (digit || space)) {
            throwFocus = false;
            $(this).trigger('change').next('input').select();
            if (space) e.preventDefault();
        }
    }).keyup(function(e) {
        throwFocus = (this.value.length === 4);
        if (throwFocus && String.fromCharCode(e.which).search(/[ .,\-\/]/) === 0) {
            e.preventDefault();
            $(this).trigger('change').next('input').select();
            throwFocus = false;
        }
    });
    parts.slice(1).keydown(function(e) {
        if (this.value.length === 0 && e.which === 8) {
            $(this).trigger('change').prev('input').focus();
        }
    });
    parts.keyup(function() {
        item.change();
    });    
    return item;    
}
};

validator.control.prototype = {
validate: function() {
    clearTimeout(this.vtimer);
    var error = this.disabled ? undefined : this.check();
    if (error !== this.error) {
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
    app.booking.validate();
}
};
