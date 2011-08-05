
// базовый класс для шагов бронирования

app.Wizard = function(el, i) {
    this.el = el;
    this.$el = $(el);
    this.index = i;

    this.ready = this.$el.hasClass('ready');

    this.init();

    return this;
};

var ptp = app.Wizard.prototype;

ptp.init = function() {

    this.$fields = this.$el.find(':input[type="text"][onclick]');
    this.$fields.inputtext(this);

    return this;
}

// форма заполнена корректно?

ptp.isValid = function() {
    this.state = this.$fields.validate();
    return this.state.length == 0;
}

// сделать блок жёлтым или зелёным

ptp.setReady = function(ready) {
    this.ready = ready;
    this.$el.toggleClass('ready', ready);
    this.$el.trigger('setready');
    return this;
}

ptp.isReady = function() {
    return this.ready;
}

ptp.change = function() {
    this.setReady(this.isValid());
    return this;
}

// возвращаем следующее текстовое поле в блоке относительно $field
ptp.nextField = function($f) {
    var $ff = this.$fields;
    return $ff.get($ff.index($f) + 1) || $ff.filter(':visible').last()[0];
}


// ======  Данные пассажиров ============


app.Person = function() {
    app.Person.superclass.constructor.apply(this, arguments)

    var $cbx = $(':checkbox', this.$el);
    
    // Имя и фамилия с проверкой раскладки
    this.names($('.text-name', this.$el));

    // чекбокс "бонусная карта"
    this.bonus($cbx.filter('.bonus'));

    // чекбокс "нет срока действия"
    this.expir($cbx.filter('.noexpiration'));
    
    // радиобаттон "Пол"
    this.sex($('.bp-sex :radio', this.$el));

    // ввод дат, два набора полей, всего шесть
    this.dates($('.text-dd', this.$el), $('.text-mm', this.$el), $('.text-yyyy', this.$el));

    // Номер документа с подсказкой
    this.passport($('.text-passport', this.$el));

    return this;
};
app.Person.extend(app.Wizard);
var ptp = app.Person.prototype;

ptp.names = function($names) {
    var warning = $names.eq(0).closest('tr').find('.language-warning');
    var mask = /[а-яё]/i;
    var active = false;
    var hwtimer, hideWarning = function() {
        clearTimeout(hwtimer);
        warning.fadeOut(150);
        active = false;
    }
    $names.keypress(function(e) {
        if (mask.test(String.fromCharCode(e.which))) {
            if (!active) {
                warning.fadeIn(150);
                active = true;
            }
            clearTimeout(hwtimer);
            hwtimer = setTimeout(hideWarning, 5000);
        } else if (active) {
            hideWarning();
        }
    }).blur(function() {
        if (active) hideWarning();
    });
    var getGender = function(name) {
        var pattern = ' ' + name.toLowerCase() + ',', gender;
        if (constants.names['m'].indexOf(pattern) !== -1) gender = 'm';
        if (constants.names['f'].indexOf(pattern) !== -1) gender = 'f';
        return gender;
    };
    $names.eq(0).blur(function() {
        var name = $(this).val();
        var controls = $(this).closest('tr').find('.bp-sex');
        if (name !== '' && controls.find('input:checked').length === 0) {
            var gender = getGender(name);
            if (gender) {
                var control = controls.filter('.bp-sex-' + gender).find('input');
                control.get(0).checked = true;
                control.change();
            }
        }
    });
    var orderWarning = $names.eq(0).closest('tr').find('.nameorder-warning');
    $names.blur(function() {
        var fn = $names.eq(0).val();
        var ln = $names.eq(1).val();
        if (fn && ln && getGender(ln) && !getGender(fn)) {
            orderWarning.fadeIn(150);
        } else {
            orderWarning.fadeOut(150);
        }
    });
    orderWarning.find('.link').click(function() {
        orderWarning.fadeOut(150);
        if ($(this).hasClass('nameorder-replace')) {
            var fn = $names.eq(0).val();
            var ln = $names.eq(1).val();
            $names.eq(0).val(ln).blur();
            $names.eq(1).val(fn);
        }
    });
};

ptp.bonus = function($el) {
    var me  = this;

    $el.click(function() {
        var cb = this;
        var data = this.onclick();
        $(data.ctrls).each(function() {
            $(this)
            .toggleClass('g-none', !cb.checked)
            .attr('disabled', !cb.checked);
        });
        $(data.label).toggleClass('g-none', !cb.checked);
        me.change();
    });
}

ptp.expir = function($el) {
    var me  = this;

    $el.click(function() {
        var cb = this;
        var data = this.onclick();
        $(data.ctrls).each(function() {
            $(this)
            .attr('disabled', cb.checked)
            .toggleClass('text-disabled', cb.checked);
        });
        $(data.label).toggleClass('label-disabled', cb.checked);
        me.change();
    });
}

ptp.sex = function($el) {
    var me  = this;

    $el.change(function() {
        $el.parent().removeClass('bp-sex-pressed bp-sex-invalid');
        $(this).parent().addClass('bp-sex-pressed');
        me.change();
    });

    // добавляем радиобаттон в коллекцию полей для валидации
    // проверяем только один баттон - остальные будут выцеплены валидатором по имени
    this.$fields = this.$fields.add($el[0]);
}

ptp.dates = function($dd, $mm, $yyyy) {
    var me  = this;
    var $ddmm = $dd.add($mm);
    
    // день и месяц - добавляем ведущий ноль
    $ddmm.change(function() {
        var v = parseInt(this.value, 10);
        if (isNaN(v)) return;

        if (!v) this.value = ''; // это был нуль
        if (v && v < 10) this.value = '0' + v;
    });
    
    var isDigit = function(code) {
        return (code > 47 && code < 58) || (code > 95 && code < 106);
    };
    
    // перескакивание в след поле после ввода валидного двухразрядного числа
    $ddmm.keyup(function(e) {
        if (!isDigit(e.which)) return;
        if (this.value.length < 2) return;

        var $el = $(this);

        var valid = !$el.validate().length;
        valid && me.nextField($el).focus();
    });
    
    // перескакивание после ввода одного числа
    $dd.keyup(function(e) {
        if (!isDigit(e.which)) return;
        var n = parseInt(this.value, 10);
        (n > 3 && n < 10) && me.nextField($(this)).focus();
    });
    $mm.keyup(function(e) {
        if (!isDigit(e.which)) return;
        var n = parseInt(this.value, 10);
        (n > 1 && n < 10) && me.nextField($(this)).focus();
    });
    
    // Из пустого поля не нужно переходить по табу
    $ddmm.add($yyyy).keydown(function(e) {
        if (e.which == 9 && !e.shiftKey && !this.value) return false;
    });


    var year = (new Date()).getFullYear();

    // если нужно, достраиваем год
    $yyyy.change(function() {
        var v = parseInt(this.value, 10);
        if (isNaN(v)) return;

        var future = $(this).attr('name').indexOf('expir') > -1;

        if (!v) {
            this.value = '';
            return;
        }
        if (v < 100) {
            this.value = (2000 + v <= year || future) ? 2000 + v : 1900 + v;
            return;
        }
        if (v < 1000) {
            this.value = 1000 + v;
            return;
        }
    });
    
    // Показываем подсказки
    $ddmm.add($yyyy).trigger('blur').removeClass('text-invalid');
}

ptp.passport = function($passport) {
    var warning = $passport.eq(0).closest('tr').find('.symbols-warning');
    var mask = /[ёа-я№#\-]/i;
    var active = false;
    var hwtimer, hideWarning = function() {
        clearTimeout(hwtimer);
        warning.fadeOut(150);
        active = false;
    }
    $passport.keypress(function(e) {
        if (mask.test(String.fromCharCode(e.which))) {
            if (!active) {
                warning.fadeIn(150);
                active = true;
            }
            clearTimeout(hwtimer);
            hwtimer = setTimeout(hideWarning, 5000);
        } else if (active) {
            hideWarning();
        }
    }).blur(function() {
        if (active) hideWarning();
    });
};

// ======  Данные банковской карты  ============

app.BankCard = function() {
    app.BankCard.superclass.constructor.apply(this, arguments)

    // отдельные элементы
    this.$type = $('#bc-type');
    this.$cvvnum = $('#bc-cvv-num');

    // номер карточки - первые 4 поля
    this.num('#bc-num1, #bc-num2, #bc-num3, #bc-num4');

    // дата протухания - два поля
    this.expir($('#bc-exp-mm'), $('#bc-exp-yy'));

    // CVV - код
    this.cvv('#bc-cvv');
    
    // Имя на карте
    this.name($('#bc-name'));

    return this;
};
app.BankCard.extend(app.Wizard);
var ptp = app.BankCard.prototype;


ptp.num = function(s) {
    var me  = this;
    var $el = $(s, this.$el);

    var isDigit = function(code) {
        return (code > 47 && code < 58) || (code > 95 && code < 106);
    };

    // перескакивание в следующее поле после ввода, в последнем это делать не нужно
    $el.slice(0, -1).keyup(function(e) {
        if (this.value.length < 4) return;
        if (!isDigit(e.which)) return;
        me.nextField($(this)).focus();
    });
    $el.keydown(function(e) {
        if (e.which == 9 && !e.shiftKey && !this.value) return false;
    });

    // перескакивание в след поле после вставки
    $el.bind('paste', function() {
        var self = this, 
            $self = $(this);

        $self.attr('maxlength', 50);

        setTimeout(function() {
            $self.attr('maxlength', 4);
            
            var v = self.value;
            if (v.length == 4) {
                me.nextField($(self)).focus();
                $self.change();
                return;
            } else if (v.length < 4) {
                return;
            }

            // сюда сложим отфильтрованную строку (только цифры)
            var s = '';
            for (var i = 0; i < v.length; i++) {
                var ch = v.charCodeAt(i);
                ch > 47 && ch < 58 && (s += v.charAt(i));
            }
            self.value = s.slice(0, 4);

            var $next = $(me.nextField($self));
            if ($el.index($next) >= 0)
                $next.val(s.slice(4)).trigger('paste')[0].focus();
        }, 50);
    });

    // если первая цифра 4, то это Виза, если 3, 5 и 6 - Мастеркард
    $el.first().keyup(function() {
        me.ctype = me.ctype || 'none';
        var ctype = me.ctype;

        switch (this.value.charAt(0)) {
            case '4':
                me.ctype = 'bc-type-visa';
                break;
            case '3':
            case '5':
            case '6':
                me.ctype = 'bc-type-master';
                break;
            default:
                me.ctype = 'bc-type-none';
        }

        if (me.ctype == ctype) return;
        
        me.$type.removeClass('bc-type-none bc-type-visa bc-type-master');
        me.$type.addClass(me.ctype);
    });
    
    // наверняка кто-нибудь попытается кликнуть в логотип карты
    me.$type.find('i').click(function() {
        me.ctype = $(this).attr('class').replace('-', '-type-');
        me.$type.removeClass('bc-type-none bc-type-visa bc-type-master');
        me.$type.addClass(me.ctype);
        $el.first().focus();
    });

    // если посл 4 цифры валидны, выводим их перед CVV, на оборотной стороне карты
    $el.last().change(function() {
        var $el = $(this);
        var valid = !$el.validate().length;
        me.$cvvnum.html(valid ? $el.val() : '<span class="empty">####</span>');
    }).keyup(function() {
        var v = parseInt(this.value, 10);
        if (isNaN(v)) {
            me.$cvvnum.html('<span class="empty">####</span>');
        } else {
            var vs = v.toString();
            var es = vs.length < 4 ? ('<span class="empty">' + '####'.substring(0, 4 - vs.length) + '</span>') : '';
            me.$cvvnum.html(vs + es);
        }
    });

}

ptp.expir = function($mm, $yy) {
    var me  = this;
    var $mmyy = $mm.add($yy);

    // добавляем ведущий ноль
    $mmyy.change(function() {
        var v = parseInt(this.value, 10);
        if (isNaN(v)) return;

        this.value = v ? v : ''; // тут был нуль
        if (v && v < 10) this.value = '0' + v;
    });

    var isDigit = function(code) {
        return (code > 47 && code < 58) || (code > 95 && code < 106);
    };    
    
    $mm.keyup(function(e) {
        if (!isDigit(e.which)) return;
        var n = parseInt(this.value, 10);
        if (n > 1 && $(this).validate().length == 0) me.nextField($(this)).focus();
    });
    $yy.keydown(function(e) {
        if (e.which == 9 && !e.shiftKey && !this.value) return false;
    });
    
}

ptp.cvv = function(s) {
    var me  = this;
    var $el = $(s, this.$el);
}

ptp.name = function($name) {
    var warning = $name.eq(0).closest('fieldset').find('.language-warning');
    var mask = /[а-я]/i;
    var active = false;
    var hwtimer, hideWarning = function() {
        clearTimeout(hwtimer);
        warning.fadeOut(150);
        active = false;
    }
    $name.keypress(function(e) {
        if (mask.test(String.fromCharCode(e.which))) {
            if (!active) {
                warning.fadeIn(150);
                active = true;
            }
            clearTimeout(hwtimer);
            hwtimer = setTimeout(hideWarning, 5000);
        } else if (active) {
            hideWarning();
        }
    }).blur(function() {
        if (active) hideWarning();
    });
};


// ======  Данные покупателя  ============

app.Contacts = function() {
    app.Contacts.superclass.constructor.apply(this, arguments)

    return this;
};
app.Contacts.extend(app.Wizard);