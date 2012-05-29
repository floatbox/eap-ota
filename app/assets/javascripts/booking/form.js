/* Booking form */
booking.form = {
init: function() {
    var that = this;
    this.sections = [];
    this.el = $('#booking-form');
    this.el.find('.bf-section').each(function() {
        var el = $(this);
        var options = booking[el.attr('data-type') + 'Options'];
        var section = new validator.Section(el, options);
        that.sections.push(section);
    });
    this.el.submit(function(event) {
        event.preventDefault();
        if (!that.button.hasClass('bfb-disabled')) {
            that.submit();
        }        
    });
    this.footer = this.el.find('.bf-footer');    
    this.footer.find('.bffc-link').click(function() {
        booking.cancel();
    });
    this.button = this.footer.find('.bf-button');
    var btitle = this.button.find('.bfb-title').click(function() {
        that.el.submit();
    });
    this.footer.css('margin-left', 20 + 325 + 7 - Math.round(btitle.width() / 2));
    this.required = this.el.find('.bff-required');
    this.required.delegate('.bffr-link', 'click', function() {
        that.focus($('#' + $(this).attr('data-field')));
    });
    this.el.delegate('.bf-hint', 'click', function(event) {
        var content = $('#' + $(this).attr('data-hint')).html();
        hint.show(event, content);
    }); 
    
    //this.sections[0].set(['mszakharov@gmail.com', '+79161234567']);
    //this.sections[1].rows[0].set(['MAXIM', 'ZAKHAROV', 'm', '03.05.1983', 170, '1234567890', '', true]);
    
    this.validate(true);
},
position: function() {
    return this.el.offset().top - 36 - results.header.height;
},
focus: function(control) {
    var st = control.offset().top - results.header.height - 71;
    $w.smoothScrollTo(Math.min(st, $w.scrollTop()), function() {
        if (control.is('input, textarea')) {
            control.select();
        } else if (control.hasClass('bfp-sex')) {
            control.find('input').eq(0).focus();
        }
    });
},
validate: function(forced) {
    var wrong = [], empty = [];
    for (var i = 0, l = this.sections.length; i < l; i++) {
        var section = this.sections[i];
        if (forced) section.validate(true);
        wrong = wrong.concat(section.wrong);
        empty = empty.concat(section.empty);
    }
    if (empty.length > 4) {
        empty[3] = 'еще ' + (empty.length - 3).decline('поле', 'поля', 'полей');
        empty.length = 4;
    }
    if (empty.length > 0) {
        wrong.push('Осталось заполнить ' + empty.enumeration(' и&nbsp;') + '.');
    }
    if (this.back) {
        this.result.hide();
        this.footer.show();
        delete this.back;    
    }
    var disabled = wrong.length !== 0;
    this.required.html(wrong.join(' ')).toggle(disabled);
    this.button.toggleClass('bfb-disabled', disabled);
},
submit: function() {
    var that = this;
    this.button.addClass('bfb-disabled');
    this.footer.find('.bff-cancel').hide();
    this.footer.find('.bff-progress').show();
    if (this.result) {
        this.result.remove();
        delete this.result;
    }
    $.ajax({
        type: 'POST',
        url: this.el.attr('action'),
        data: this.el.serialize(),
        success: function(s) {
            that.process(s);
        },
        error: function() {
            that.process('<div class="bf-result bfr-fail"><h5 class="bfr-title">Что-то пошло не так.</h5><p class="bfr-content">Возникла техническая проблема. Попробуйте нажать на кнопку «Купить» ещё раз или позвоните нам <nobr>(+7 495 660-35-20) &mdash;</nobr> мы&nbsp;разберемся.</p><p class="bfr-content"><span class="link bfr-back">Попробовать ещё раз</span></p></div>');
        }
    });
},
process: function(s) {
    this.footer.hide();
    this.footer.find('.bff-progress').hide();
    this.footer.find('.bff-cancel').show();
    this.button.removeClass('bfb-disabled');
    var that = this;
    this.result = $(s).insertAfter(this.el);
    this.result.find('.bfr-cancel').click(function() {
        booking.cancel();
    });
    this.result.find('.bfr-continue').click(function() {
        $(this).closest('.bf-result').find('form').submit();
    });
    var back = this.result.find('.bfr-back');
    if (back.length) {  
        that.back = true;
        back.click(function() {
            that.result.hide();
            that.footer.show();
            delete that.back;
        });
    }
    if (this.result.attr('data-type') === 'forbidden') {
        setTimeout(function() {
            that.result.hide();
            that.footer.show();
        }, 6000);
    }
}
};

/* Contacts section */
booking.contactsOptions = {
init: function() {
    var that = this;
    this.initEmail();
    this.initPhone();
    this.bind(function() {
        that.validate();
        booking.form.validate();    
    });
},
initEmail: function() {
    var email = new validator.Text($('#bfc-email'), {
        empty: '{адрес электронной почты}',
        wrong: 'Неправильно введен {адрес электронной почты}.'
    }, function(value) {
        if (/^[@.\-]|[^\w\-.@]|@.*[^\w.\-]/.test(value)) return 'wrong';
        if (!/^\S*?@[\w.\-]*?\.\w{2,3}$/.test(value)) return 'empty';
    });
    this.controls.push(email);
},
initPhone: function() {
    var phone = new validator.Text($('#bfc-phone'), {
        empty: '{номер телефона}',
        letters: 'В {номере телефона} можно использовать только цифры.',
        short: 'Короткий {номер телефона}, не забудьте ввести код города.'
    }, function(value) {
        if (/[^\d() \-+]/.test(value)) return 'letters';
        var digits = value.replace(/\D/g, '').length;
        if (digits < 5) return 'empty';
        if (digits < 8) return 'short';
    });
    phone.format = function(value) {
        var v = $.trim(value);
        v = v.replace(/(\d)\(/, '$1 (');
        v = v.replace(/\)(\d)/, ') $1');
        v = v.replace(/(\D)(\d{2,3}) ?(\d{2}) ?(\d{2})$/, '$1$2-$3-$4');
        return v;
    };
    this.controls.push(phone);    
}
};

/* Persons section */
booking.personsOptions = {
init: function() {
    var that = this;
    this.latinWarning = $('#bfw-name-latin');
    this.orderWarning = $('#bfw-name-order');
    this.rows = this.el.find('.bfp-row').map(function() {
        return new validator.Person($(this), that);
    });
    this.orderWarning.find('.bfwno-replace').click(function() {
        var person = that.orderWarning.person;
        var fn = person.firstname.el.val();
        var ln = person.lastname.el.val();
        person.firstname.set(ln);
        person.lastname.set(fn);
        that.orderWarning.fadeOut(50);
    });
    this.orderWarning.find('.bfwno-leave').click(function() {
        that.orderWarning.fadeOut(50);
    });
},
validate: function(forced) {
    var wrong = [], empty = [];
    for (var i = 0, l = this.rows.length; i < l; i++) {
        var person = this.rows[i];
        if (forced) person.validate(true);
        wrong = wrong.concat(person.wrong);
        empty = empty.concat(person.empty);
    }
    this.toggle(wrong.length + empty.length === 0);
    this.wrong = wrong;
    this.empty = empty;
}
};

/* Person constructor */
validator.Person = function(el, section) {
    this.el = el;
    this.section = section;
    this.controls = [];
    this.init();
};
validator.Person.prototype = $.extend({}, validator.Section.prototype, {
init: function() {
    var that = this;
    this.initNames();
    this.initSex();
    this.initBirthday();
    this.initNationality();    
    this.initPassport();
    this.initExpiration();    
    this.initBonus();
    this.bind(function() {
        that.validate();
        that.section.validate();
        booking.form.validate();        
    });
},
initNames: function() {
    var that = this;
    var lwarning = this.section.latinWarning;
    var owarning = this.section.orderWarning;    
    var check = function(value) {
        if (/[а-яё]/.test(value)) {
            lwarning.css('top', this.el.offset().top + 34);
            if (owarning.is(':visible')) {
                owarning.hide();
                lwarning.show();
            } else {
                lwarning.fadeIn(100);
            }
            return 'letters';
        } else {
            lwarning.fadeOut(50);
        }
        if (/[^A-Za-z\- ']/.test(value)) return 'letters';
        if (value.length < 2) return 'short';
    };
    this.firstname = new validator.Text(this.el.find('.bfp-fname'), {
        empty: '{имя пассажира}',
        short: '{Имя пассажира} нужно ввести полностью.',
        letters: '{Имя пассажира} нужно ввести латинскими буквами.'
    }, check);
    this.lastname = new validator.Text(this.el.find('.bfp-lname'), {
        empty: '{фамилию пассажира}',
        short: '{Фамилию пассажира} нужно ввести полностью.',
        letters: '{Фамилию пассажира} нужно ввести латинскими буквами.'
    }, check);
    this.firstname.format = this.lastname.format = function(value) {
        var name = $.trim(value);
        this.gender = name && validator.getGender(name);
        that.processNames();
        return name.toUpperCase();
    };
    this.controls.push(this.firstname, this.lastname);
},
processNames: function() {
    var fng = this.firstname.gender;
    var lng = this.lastname.gender;
    if (fng && this.gender.error) {
        this.gender.set(fng);
    }
    if (lng && !fng) {
        var top = this.firstname.el.offset().top + 34;
        var lwarning = this.section.latinWarning;
        var owarning = this.section.orderWarning.css('top', top);
        if (lwarning.is(':visible')) {
            lwarning.hide();
            owarning.show();
        } else {
            owarning.fadeIn(100);
        }
        owarning.person = this;
    }
},
initSex: function() {
    this.gender = new validator.Gender(this.el.find('.bfp-sex'));
    this.controls.push(this.gender);
},
initBirthday: function() {
    var date = this.el.find('.bfp-date').eq(0);
    var birthday = new validator.Date(date, {
        empty: '{дату рождения} пассажира',
        wrong: 'Указана несуществующая {дата рождения} пассажира.',
        letters: '{Дату рождения} пассажира нужно ввести цифрами в формате дд/мм/гггг.',
        improper: '{Дата рождения} пассажира не может быть позднее сегодняшней.'
    }, function(date) {
        if (date.getTime() > this.ctime) return 'improper';
    });
    this.controls.push(birthday);
},
initNationality: function() {
    var nationality = new validator.Select(this.el.find('.bfp-nationality'));
    this.controls.push(nationality);
},
initPassport: function() {
    var that = this;
    var passport = new validator.Text(this.el.find('.bfp-passport'), {
        empty: '{номер документа} пассажира',
        letters: 'В {номере документа} нужно использовать только буквы и цифры.'
    }, function(value) {
        if (/[^\wА-Яа-я. \-№#]/.test(value)) return 'letters';
        if (value.length < 5) return 'empty';
    });
    passport.format = function(value) {
        return $.trim(value.toUpperCase().replace(/[^A-ZА-Я\d]/g, ''));
    };
    this.controls.push(passport);
},
initExpiration: function() {
    var expiration = new validator.Date(this.el.find('.bfp-date').eq(1), {
        empty: '{срок действия документа} пассажира',
        wrong: 'Указана несуществующая дата в {сроке действия документа} пассажира.',
        letters: '{Срок действия документа} нужно ввести цифрами в формате дд/мм/гггг.',
        improper: '{Срок действия документа} уже истёк.'
    }, function(date) {
        if (date.getTime() < this.ctime) return 'improper';
    });
    expiration.future = true;
    var permanent = {
        disabled: true,
        el: this.el.find('input[id$="permanent"]'),
    };
    permanent.set = function(value) {
        this.el.prop('checked', Boolean(value)).trigger('set');
    };
    permanent.el.bind('click set', function(event) {
        expiration.disabled = this.checked;
        with (expiration) {
            el.toggleClass('bf-disabled', disabled);
            parts.toggleClass('bf-disabled', disabled)
            parts.prop('disabled', disabled);
            validate();
        }
        if (event.type !== 'set') {
            expiration.parts.eq(0).select();
            expiration.apply();
        }
    });
    this.controls.push(expiration, permanent);
},
initBonus: function() {
    var checkbox = this.el.find('input[id$="bonus"]');
    if (checkbox.length === 0) return;
    var row = this.el.find('.bfp-bonus-fields');
    var program = new validator.Select(this.el.find('.bfp-bonus-type'));
    this.controls.push(program);
    var number = new validator.Text(row.find('.bfp-bonus-number'), {
        empty: '{номер бонусной карты} пассажира',
        letters: '{Номер бонусной карты} нужно ввести латинскими буквами и цифрами.',
    }, function(value) {
        if (/[^\w \-№#]/.test(value)) return 'letters';
        if (value.length < 5) return 'empty';
    });
    number.disabled = true;
    number.format = function(value) {
        return $.trim(value.toUpperCase().replace(/[^A-Z\d]/g, ''));
    };
    checkbox.click(function() {
        var disabled = !this.checked;
        row.find('select').prop('disabled', disabled);
        row.toggleClass('latent', disabled);
        number.el.prop('disabled', disabled);
        number.disabled = disabled;
        number.validate();
        number.apply();
        if (this.checked) {
            number.el.focus();
        }
    });
    this.controls.push(number);
},
toggle: function(ready) {
    this.el.toggleClass('.bfp-ready', ready);
}
});

/* Payment section */
booking.paymentOptions = {
init: function() {
    var that = this;
    this.initCard();
    this.initCash();
    this.bind(function() {
        that.validate();
        booking.form.validate();    
    });
    if (this.cash) {
        $('#bfcd-yes').trigger('set');
        this.initSelector();
        this.select('card');
    }
},
initCard: function() {
    var context = this.el.find('.bf-card');
    
    // Тип карты
    var sample = $('#bfcn-sample');
    var type, types = {
        '4': 'visa',
        '3': 'mastercard',
        '5': 'mastercard',
        '6': 'mastercard'
    };
    var typeParts = {
        visa: context.find('.bfct-visa'),
        mastercard:  context.find('.bfct-mastercard'),
        or: context.find('.bfct-or')
    };
    var toggleType = function(t) {
        if (t === type) return;
        typeParts.visa.toggle(t !== 'mastercard');
        typeParts.mastercard.toggle(t !== 'visa');
        typeParts.or.toggle(t === undefined);            
        type = t;
    };
    typeParts.visa.click(function() {
        toggleType('visa');
        number.parts.first().focus();
    });
    typeParts.mastercard.click(function() {
        toggleType('mastercard');
        number.parts.first().focus();
    });    
    
    // Номер карты
    var number = new validator.CardNumber(context.find('.bfcn-parts'), {
        empty: '{номер банковской карты}',
        letters: '{Номер банковской карты} нужно ввести цифрами.',
        wrong: '{Номер банковской карты} введён неправильно.'
    });
    number.parts.last().bind('keyup propertychange input change', function() {
        var value = ($(this).val() + '----').substring(0, 4);
        sample.html(value.replace(/\D/g, '<span class="bfcn-empty">#</span>'));
    });
    number.parts.first().bind('keyup propertychange input', function() {
        var v = this.value;
        toggleType(v ? types[v.charAt(0)] : undefined);
    });    

    // CVV
    var cvv = new validator.Text($('#bc-cvv'), {
        empty: '{CVV/CVC код банковской карты}',
        letters: '{CVV/CVC код банковской карты} нужно ввести цифрами.',
    }, function(value) {
        if (/\D/.test(value)) return 'letters';
        if (value.length < 3) return 'empty';
    });

    // Имя владельца
    var name = new validator.Text($('#bfc-name'), {
        empty: '{имя владельца банковской карты}',
        letters: '{Имя владельца банковской карты} нужно ввести латинскими буквами.',
    }, function(value) {
        if (/[^A-Za-z\- .']/.test(value)) return 'letters';
    });
    name.format = function(value) {
        return $.trim(value).toUpperCase();    
    };
    
    // Срок действтия
    var date = new validator.CardDate(context.find('.bfc-date'), {
        empty: '{срок действия банковской карты}',
        letters: '{Срок действия банковской карты} нужно ввести цифрами в формате мм/гг.',
        wrong: 'Месяц в {сроке действия банковской карты} не может быть больше 12.',
        improper: '{Срок действия банковской карты} уже истёк.'
    }, function(value) {
        if (/[^A-Za-z\- .']/.test(value)) return 'letters';
    });
   
    // Меняем отступы полей, чтобы цифры выравнивались по центру
    var npw = number.parts.first().outerWidth() - 1;
    var npp = Math.floor((npw - sample.width()) / 2) - 1;
    number.parts.width(npw - npp * 2).css('padding-left', npp).css('padding-right', npp);
    cvv.el.width(Math.ceil((npw - npp * 2) * 0.75));    

    this.controls.push(number, cvv, name, date);
    this.card = {
        el: context,
        controls: [number, cvv, name, date]
    };
},
initCash: function() {
    var context = this.el.find('.bf-cash');
    if (context.length === 0) {
        return false;
    }
    
    // Доставка иди оплата в офисе
    context.find('.bfcd-radio').bind('click set', function(event) {
        var value = $(this).attr('value');
        context.find('.bfc-address').toggle(value === 'delivery');
        context.find('.bfc-contacts').toggle(value === 'cash');
        address.disabled = (value === 'cash');
        $('#bfpt-cash').attr('value', value);
        if (event.type === 'click') {
            address.apply();
            if (!address.disabled) {
                address.el.focus();
            }
        }
        var price = booking.form.el.find('.bffp-content');
        price.find('.bffp-wd').toggle(value === 'delivery');
        price.find('.bffp-nd').toggle(value !== 'delivery');
    });

    // Адрес доставки
    var address = new validator.Text($('#bc-address'), {
        empty: '{адрес доставки}'
    }, function(value) {
        if (value.length < 5 || !/\d/.test(value)) return 'empty';
    });

    this.controls.push(address);
    this.cash = {
        el: context,
        controls: [address]
    };    
},
initSelector: function() {
    var that = this;
    this.el.find('.bfpt-radio').click(function() {
        that.select($(this).attr('value') === 'card' ? 'card' : 'cash', true);
    });
},
select: function(type, validate) {
    this.card.el.toggle(type === 'card');
    this.cash.el.toggle(type === 'cash');
    this.card.el.find('input').prop('disabled', type !== 'card');
    this.cash.el.find('input').prop('disabled', type !== 'cash');    
    this.controls = this[type].controls;
    var context = booking.form.el;
    var wd = (type === 'cash' && $('#bfcd-yes').is(':checked'));
    context.find('.bffd-card').toggleClass('latent', type !== 'card');
    context.find('.bffd-cash').toggleClass('latent', type !== 'cash');
    context.find('.bffp-wd').toggle(wd);
    context.find('.bffp-nd').toggle(!wd);
    if (validate) {
        this.validate(true);
        booking.form.validate();
    }
}
};
