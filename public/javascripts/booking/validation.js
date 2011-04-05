app.booking.validate = function(full) {
    var errors = [];
    for (var s = 0, sm = this.sections.length; s < sm; s++) {
        var valid = true;
        var section = this.sections[s];
        for (var i = 0, im = section.items.length; i < im; i++) {
            var item = section.items[i];
            if (full) {
                item.validate();
            }
            if (item.error) {
                errors.push(item.error);
                valid = false;
            }
        }
        section.el.toggleClass('ready', valid);
    }
    if (errors.length) {
        //console.log(errors);
    }
};
app.booking.initPerson = function(el) {
    var items = [];
    items.push(this.controls.name(el.find('input[id$="first_name"]'), {
        empty: 'Не указано {имя пассажира}',
        short: '{Имя пассажира} не может быть таким коротким',
        latin: '{Имя пассажира} нужно ввести латинскими буквами'
    }));
    items.push(this.controls.name(el.find('input[id$="last_name"]'), {
        empty: 'Не указана {фамилия пассажира}',
        short: '{Фамилия пассажира} не может быть такой короткой',
        latin: '{Фамилию пассажира} нужно ввести латинскими буквами'
    }));
    items.push(this.controls.gender(el.find('.bp-sex-radio'), {
        empty: 'Не выбран {пол пассажира}'
    }));
    items.push(this.controls.date(el.find('.bp-birthday input'), {
        empty: 'Не указана {дата рождения} пассажира',
        letters: '{Дату рождения} нужно ввести цифрами в формате дд/мм/гггг',
        incomplete: '{Дата рождения} не введена полностью',
        unreal: 'Указана несуществующая {дата рождения}',
        future: '{Дата рождения} не может быть позднее сегодняшней'
    }));
    this.sections.push({
        el: el,
        items: items
    });
};

app.booking.controls = {
error: function(el, text) {
    text = text.replace('{', '<spanc class="link" data-field="' + el.attr('id') + '">');
    text = text.replace('}', '</span>');
    return text;
},
name: function(el, errors) {
    var that = this;
    var item = {};
    var vtimer; 
    item.check = function() {
        var value = $.trim(el.val());
        if (!value) return 'empty';
        if (value.search(/[^a-z]/i) !== -1) return 'latin';
        if (value.length < 2) return 'short';
        return undefined;
    }
    item.validate = function() {
        clearTimeout(vtimer);
        var error = item.check();
        item.error = error && that.error(el, errors[error]);
        el.toggleClass('bf-invalid', error === 'latin');
        el.toggleClass('bf-valid', !error);
    };
    item.format = function() {
        el.val($.trim(el.val().toUpperCase()));
    };
    var validate = function() {
        item.validate();
    };
    el.keyup(function() {
        clearTimeout(vtimer);
        vtimer = setTimeout(validate, 300);
    });
    el.change(function() {
        item.validate();
        if (!item.error) {
            item.format();
        }
    });
    return item;
},
gender: function(radio, errors) {
    var item = {}, that = this;
    item.validate = function() {
        if (radio.filter(':checked').length > 0) {
            item.error = undefined;
        } else {
            item.error = that.error(radio.eq(0).parent(), errors.empty);
        }
    };
    radio.click(function() {
        var value = $(this).attr('value');
        var labels = $(this).closest('.bp-sex').find('label');
        labels.removeClass('selected');
        labels.filter('.bp-sex-' + value).addClass('selected');
        item.validate();
    });
    return item;        
},
date: function(parts, errors) {
    var that = this;
    var df = parts.eq(0);
    var mf = parts.eq(1);
    var yf = parts.eq(2);
    var item = {};
    var today = new Date();
    item.check = function() {
        var d = df.val(), m = mf.val(), y = yf.val(), dmy = d + m + y;
        if (dmy.length === 0) return 'empty';
        if (dmy.search(/[^\d]/) !== -1) return 'letters';
        if (!(d && m && y)) return 'incomplete';
        var dv = parseInt(d, 10);
        var mv = parseInt(m, 10) - 1;
        var yv = parseInt(y, 10);
        if (yv < today.getFullYear() % 100) yv += 2000;
        if (yv < 1000) yv = 1900 + yv % 100;
        var value = new Date(yv, mv, dv, 12);
        if (value.getDate() !== dv || value.getMonth() !== mv || value.getFullYear() !== yv) return 'unreal';
        if (value.getTime() > today.getTime()) return 'future';
        return undefined;        
    };
    item.validate = function() {
        var error = item.check();
        item.error = error && that.error(df, errors[error]);
        parts.toggleClass('bf-invalid', error === 'letters' || error === 'unreal');
        parts.toggleClass('bf-valid', !error);        
    };
    item.format = function() {
        var d = df.val();
        var m = mf.val();
        if (d.length < 2) df.val('0' + d);
        if (m.length < 2) mf.val('0' + m);
        var y = parseInt(yf.val(), 10);
        if (y < today.getFullYear() % 100) y += 2000;
        if (y < 1000) y = 1900 + y % 100;
        yf.val(y);
    };
    parts.focus(function() {
        $(this).prev('.placeholder').hide();
    });
    parts.blur(function() {
        var f = $(this);
        f.prev('.placeholder').toggle(f.val().length === 0);
    });
    parts.change(function() {
        item.validate();
        if (!item.error) {
            item.format();
        }        
    });
    return item;
}
};
