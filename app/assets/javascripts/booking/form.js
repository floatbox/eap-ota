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
    this.el.on('submit', function(event) {
        event.preventDefault();
        if (!that.sending) {
            if (that.button.hasClass('bfb-disabled')) {
                that.validate(true); // если вдруг не отследили изменение какого-то поля
            }
            if (that.button.hasClass('bfb-disabled')) {
                var rtext = that.required.text();
                if (rtext) {
                    trackEvent('Бронирование', 'Нажатие заблокированной кнопки', rtext);
                } else {
                    trackEvent('Бронирование', 'Заблокированная кнопка без ошибок', that.getValues());
                }
                that.required.find('.bffr-link').eq(0).click();
            } else {
                that.submit();
            }
        }
    });
    this.el.on('change', function() {
        clearTimeout(that.vtimer);
        that.vtimer = setTimeout(function() {
            that.validate(true);
        }, 100);
    });
    this.footer = this.el.find('.bf-footer');
    this.footer.find('.bffc-link').click(function() {
        booking.cancel();
    });
    this.button = this.footer.find('.bf-button');
    var btitle = this.button.find('.bfb-title').click(function() {
        that.el.submit();
    });
    if (!this.iphoneLayout) {
        var offset = 325 + 7 - Math.round(btitle.width() / 2);
        this.footer.find('.bff-left').width(offset - 40);
        this.footer.find('.bff-right').css('margin-left', offset);
    }
    this.required = this.el.find('.bff-required');
    this.required.on('click', '.bffr-link', function() {
        that.focus($('#' + $(this).attr('data-field')));
    });
    this.wrongPrice = false;
    this.sending = false;
    this.validate(true);
    if (typeof sessionStorage !== 'undefined') {
        for (var i = this.sections.length; i--;) {
            var section = this.sections[i];
            if (section.load) {
                section.load();
            }
        }
        this.validate(true);        
    }
},
position: function() {
    return this.el.offset().top - 36 - results.header.height;
},
focus: function(control) {
    if (browser.ios) {
        control.focus().select();
    } else {
        var st = control.offset().top;
        if (!this.iphoneLayout) {
            st -= results.header.height + 71
        }
        $w.smoothScrollTo(Math.min(st, $w.scrollTop()), function() {
            if (control.is('input, textarea')) {
                control.select();
            } else if (control.hasClass('bfp-sex')) {
                control.find('input').eq(0).focus();
            }
        });
    }
},
validate: function(forced) {
    var wrong = [], empty = [];
    for (var i = 0, im = this.sections.length; i < im; i++) {
        var section = this.sections[i];
        if (forced) section.validate(true);
        for (var l = 0, lm = section.wrong.length; l < lm; l++) {
            if (section.wrong[l]) wrong.push(section.wrong[l]);
        }
        for (var l = 0, lm = section.empty.length; l < lm; l++) {
            if (section.empty[l]) empty.push(section.empty[l]);
        }
    }
    var disabled = false;
    this.required.html('');
    if (wrong.length) {
        this.required.append('<p class="bffr-wrong">' + wrong.join(' ') + '</p>');
        disabled = true;
    }
    if (empty.length > 4) {
        empty[3] = lang.formValidation.otherFields(empty.length - 3);
        empty.length = 4;
    }
    if (empty.length > 0) {
        this.required.append('<p class="bffr-empty">' lang.formValidation.emptyFields(empty) + '</p>');
        disabled = true;
    }
    if (this.back) {
        this.result.hide();
        this.footer.show();
        delete this.back;
    }
    if (!this.sending) {
        this.button.toggleClass('bfb-disabled', disabled);
        this.required.toggle(disabled);
    }
},
submit: function() {
    var that = this;
    this.sending = true;
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
            if (typeof s === 'string' && s.length) {
                that.process(s);
            } else if (s && s.errors) {
                that.showErrors(s.errors);
            } else if (s && s.exception && s.exception.message) {
                that.showErrors({'exception': s.exception.message});
            }
        },
        error: function() {
            that.process('<div class="bf-result bfr-fail"><h5 class="bfr-title">Что-то пошло не так.</h5><p class="bfr-content">Возникла техническая проблема. Попробуйте нажать на кнопку «Купить» ещё раз или позвоните нам <nobr>(+7 495 660-35-20) &mdash;</nobr> мы&nbsp;разберемся.</p><p class="bfr-content"><span class="link bfr-back">Попробовать ещё раз</span></p></div>');
        }
    });
},
showErrors: function(errors) {
    var wrong = [], cardused = false;
    for (var id in errors) {
        if (id.search('birthday') !== -1) {
            var n = Number(id.charAt(7));
            wrong.push('<span class="bffr-link" data-field="bfp' + (n + 1) + '-byear">Пассажиру</span> ' + errors[id] + '.');
        } else if (id.search('passport') !== -1) {
            var n = Number(id.charAt(7));
            wrong.push('<span class="bffr-link" data-field="bfp' + (n + 1) + '-passport">Номер документа</span> введен неправильно.');
        } else if (id.search('card') !== -1 && !cardused) {
            wrong.push('<span class="bffr-link" data-field="bfcn-part4">Номер банковской карты</span> введён неправильно.');
            cardused = true;
        } else {
            wrong.push(errors[id]);
        }
    }
    this.required.html(wrong.join(' ')).show();
    this.button.removeClass('bfb-disabled');
    this.footer.find('.bff-progress').hide();
    this.footer.find('.bff-cancel').show();
    this.sending = false;
},
process: function(s) {
    this.footer.hide();
    this.footer.find('.bff-progress').hide();
    this.footer.find('.bff-cancel').show();
    this.button.removeClass('bfb-disabled');
    this.sending = false;
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
        this.back = true;
        back.click(function() {
            that.result.hide();
            that.footer.show();
            delete that.back;
        });
    }
    switch (this.result.attr('data-type')) {
    case 'newprice':
        var op = Number(this.el.find('.bf-newprice').attr('data-price'));
        var np = Number(this.result.find('.bfnp-data').attr('data-price'));
        if (op === np) {
            that.el.submit();
            that.footer.show();
            return;
        } else {
            booking.processPrice(this.result, np - op);
            trackEvent('Бронирование', 'Изменилась цена', np - op > 0 ? 'Стало дороже' : 'Стало дешевле');
            this.result.find('.obb-title').click(function() {
                that.el.submit();
                that.footer.show();
            });
            this.updatePrice(this.result.find('.bfnp-data'));
            this.back = true;
        }
        break;
    case '3dsecure':
        this.result.find('.obb-title').click(function() {
            $(this).closest('.bf-result').find('form').submit();
        });
        break;
    case 'forbidden':
        setTimeout(function() {
            that.result.hide();
            that.footer.show();
        }, 60000);
        break;
    case 'success':
        trackPage('/booking/success');
        if (window._gaq) {
            var price = this.el.find('.bf-newprice').attr('data-price');
            _gaq.push(['_addTrans', this.result.find('.bfr-pnr').text(), '', price]);
            _gaq.push(['_trackTrans']);
        }
        this.result.find('.bfrsi-link').click(function() {
            trackEvent('Бронирование', 'Переход на страницу страховки');        
        });
        this.sending = true; // не даём отправить форму второй раз
        this.el.find('.bfp-add, .bfp-remove').css('visibility', 'hidden');
        this.el.find('input, textarea, select').prop('disabled', true);
        break;
    }
    var spos = $('#page-footer').offset().top - $w.height();
    if ($w.scrollTop() < spos) {
        $w.smoothScrollTo(spos);
    }
},
hidePrice: function() {
    this.footer.find('.bff-passengers').remove();
    var content = '<div class="bffp-content"><p>Стоимость изменилась —</p><p class="bffp-hint">Заполните {0},<br> чтобы узнать новую стоимость.</p></div>';
    var title = lang.passengersData[this.el.find('.bf-persons .bfst-text').attr('data-amount')];
    var message = $('<div class="bff-passengers"></div>').html(content.absorb(title));
    this.footer.find('.bff-price').hide().after(message);
    this.wrongPrice = true;
},
getPrice: function() {
    var that = this;
    $.ajax({
        type: 'POST',
        url: '/booking/recalculate_price',
        data: this.el.serialize(),
        success: function(s) {
            if (typeof s === 'string' && s.length) {
                that.updatePrice($(s).find('.bfnp-data'));
            } else {
                that.footer.find('.bff-passengers').remove();
            }
        },
        error: function() {
            that.footer.find('.bff-passengers').remove();
        }
    });
    this.footer.find('.bff-passengers .bffp-content').html('<p class="bffp-progress">Обновляем стоимость &mdash;</p>');
    this.wrongPrice = false;
},
updatePrice: function(content) {
    this.footer.find('.bff-passengers').remove();
    this.footer.find('.bff-price').show();
    var wd = this.footer.find('.bff-price .bffp-wd').is(':visible');
    var context = this.footer.find('.bff-price .bffp-content').html(content.html());
    context.find('.bffp-wd').toggle(wd);
    context.find('.bffp-nd').toggle(!wd);
    this.el.find('.bf-newprice').attr('data-price', content.attr('data-price'));
},
getValues: function() {
    var result = [];
    var data = this.el.serializeArray();
    for (var i = 3, im = data.length; i < im; i++) {
        var value = data[i].value;
        if (data[i].name.indexOf('card') !== -1) {
            value = value.replace(/\d/g, 'X');
        }
        result.push('"' + value + '"');
    }
    return result.join(' ');
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
    var email = new validator.Text($('#bfc-email'), lang.formValidation.email, function(value) {
        if (/^[@.\-]|[^\w\-\+.@]|@.*[^\w.\-]/.test(value)) return 'wrong';
        if (!/^\S*?@[\w.\-]*?\.\w{2,}$/.test(value)) return 'empty';
    });
    this.controls.push(email);
},
initPhone: function() {
    var phone = new validator.Text($('#bfc-phone'), lang.formValidation.phone, function(value) {
        if (/[^\d() \-+]/.test(value)) return 'letters';
        var digits = value.replace(/\D/g, '').length;
        if (digits < 5) return 'empty';
        if (digits < 9) return 'short';
    });
    if (!phone.el.val()) {
        phone.el.val('+7');
    }
    var phoneField = phone.el.get(0);
    var moveFocus = function() {
        var pos = phoneField.value.length;
        phoneField.setSelectionRange(pos, pos);
    };
    phone.el.on('focus', function() {
        if (this.value === '+7') {
            window.setTimeout(moveFocus, 10);
        }
    });
    phone.el.on('keyup propertychange input paste', function() {
        if (!this.value) {
            this.value = '+';
            window.setTimeout(moveFocus, 10);
        }
    });
    phone.format = function(value) {
        var v = $.trim(value);
        v = v.replace(/[^+\d]/g, '');
        v = v.replace(/^8(\d+)/g, '+7$1');
        v = v.replace(/^(\d)/g, '+$1');        
        return v;
    };
    this.controls.push(phone);
},
save: function() {
    sessionStorage.setItem('contactsData', '["' + this.get().join('", "') + '"]');
},
load: function() {
    var that = this;
    this.set($.parseJSON(sessionStorage.getItem('contactsData')) || []);
    this.el.change(function() {
        that.save();
    });    
}
};

/* Persons section */
booking.personsOptions = {
init: function() {
    var that = this;
    this.latinWarning = $('#bfw-name-latin');
    this.orderWarning = $('#bfw-name-order');
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
    this.title = this.el.find('.bfst-text');
    this.table = this.el.find('.bfp-table');
    this.add = this.el.find('.bfp-add');
    this.add.find('.bfpa-link').click(function() {
        booking.form.wrongPrice = false;
        var data = that.savedRows && that.savedRows[that.rows.length];
        var row = that.addRow(that.rows.length);
        that.applyRows();
        if (data) {
            row.set(data);
        }
        booking.form.hidePrice();
        that.validate(true);
        booking.form.validate();
    });
    this.table.on('click', '.bfpr-link', function() {
        booking.form.wrongPrice = false;
        that.removeRow(Number($(this).closest('tbody').attr('data-index')));
        booking.form.hidePrice();        
        that.validate(true);
        booking.form.validate();
    });
    this.lastFlightDate = Date.parseDMY(this.table.attr('data-date'));
    this.sample = this.el.find('.bfp-row').remove();
    this.rows = [];
    this.rowsLimit = Math.min(8, Number(this.table.attr('data-max')));
    this.cachedPeople = this.table.attr('data-people') + '0';
    var total = Number(this.table.attr('data-total'));
    for (var i = 0; i < total; i++) {
        this.addRow(i);
    }
    this.applyRows();
},
save: function() {
    var data = [];
    for (var i = this.rows.length; i--;) {
        this.savedRows[i] = this.rows[i].get();
    }
    for (var i = 0, im = this.savedRows.length; i < im; i++) {
        data.push('["' + this.savedRows[i].join('", "') + '"]');
    }
    sessionStorage.setItem('personsAmount', this.rows.length);
    sessionStorage.setItem('personsData', '[' + data.join(', ') + ']');
},
load: function() {
    var that = this;
    var data = $.parseJSON(sessionStorage.getItem('personsData')) || [];
    var amount = Math.min(Number(sessionStorage.getItem('personsAmount')) || this.rows.length, this.rowsLimit);
    var wrongPrice = amount !== this.rows.length;
    for (var i = 0; i < amount; i++) {
        var rd = data[i];
        var row = this.rows[i] || this.addRow(i);
        if (rd) {
            // Убираем бонусную карту, если нужной нет в списке
            if (row.programIndex && rd.length > row.programIndex && rd[row.programIndex]) {
                var programs = row.controls[row.programIndex].values;
                if (!programs[rd[row.programIndex]]) {
                    rd.length = row.programIndex - 1;
                }
            }
            this.rows[i].set(rd);
        }
    }
    if (wrongPrice) {
        booking.form.hidePrice();
    }
    this.savedRows = data;
    this.applyRows();
    this.table.change(function() {
        that.save();
    });
},
addRow: function(index) {
    var that = this;
    var temp = $('<div><table></table></div>');
    temp.find('table').append(this.sample.clone());
    temp.html(temp.html().replace(/\$n/g, index.toString()));
    var row = temp.find('tbody').appendTo(this.table).attr('data-index', index);
    this.rows[index] = new validator.Person(row, that);
    return this.rows[index];
},
removeRow: function(index) {
    for (var i = index, im = this.rows.length - 1; i < im; i++) {
        this.rows[i].set(this.rows[i + 1].get());
    }
    this.rows[this.rows.length - 1].el.remove();
    this.rows.length--;
    if (this.savedRows) {
        this.savedRows.splice(this.rows.length, 1);
    }
    if (this.rows.length === 0) {
        this.addRow(0);
    }
    this.table.trigger('change');
    this.applyRows();
    this.validate(true);
},
applyRows: function() {
    var n = this.rows.length, key = n === 1 ? 'one' : 'many';
    this.add.toggle(n < this.rowsLimit);
    this.title.attr('data-amount', key).html(lang.passengers[key]);
},
validate: function(forced) {
    var wrong = [], empty = [], people = {a: 0, c: 0, i: 0, is: 0};
    for (var i = 0, im = this.rows.length; i < im; i++) {
        var person = this.rows[i];
        if (forced) person.validate(true);
        wrong = wrong.concat(person.wrong);
        if (im === 1) {
            empty = empty.concat(person.empty);
        } else if (person.empty) {
            var num = lang.ordinalNumbers.gen[i];
            for (var e = 0, em = person.empty.length; e < em; e++) {
                empty.push(person.empty[e].replace('пассажира', num + ' пассажира'));
            }
        }
        if (person.type) {
            people[person.type]++;
            if (person.type === 'i' && person.seat) {
                people['is']++;
            }
        }
    }
    if (people.a + people.c + people.i === this.rows.length) {
        if (people.a === 0 && people.c + people.i > 0) {
            wrong.push(lang.searchRequests.noadults + '.');
        }
        var merged = [people.a, people.c, people.i, people.is].join('');
        if (merged !== this.cachedPeople) {
            booking.form.hidePrice();
            this.cachedPeople = merged;
        }
    }
    clearTimeout(this.getPriceTimeout);
    var valid = wrong.length + empty.length === 0;
    if (valid && booking.form.wrongPrice) {
        this.getPriceTimeout = setTimeout(function() { 
            booking.form.getPrice();
        }, 100);
    }    
    this.toggle(valid);
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
    this.firstname = new validator.Text(this.el.find('.bfp-fname'), lang.formValidation.fname, check);
    this.lastname = new validator.Text(this.el.find('.bfp-lname'), lang.formValidation.lname, check);
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
    if (lng && !fng && !this.firstname.error) {
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
    this.gender = new validator.Gender(this.el.find('.bfp-sex'), lang.formValidation.gender);
    this.controls.push(this.gender);
},
initBirthday: function() {
    var that = this;
    var date = this.el.find('.bfp-date').eq(0);
    var birthday = new validator.Date(date, lang.formValidation.birthday, function(date) {
        if (date.getTime() > this.time) return 'improper';
    });
    var withseat = new validator.Checkbox(this.el.find('.bfpo-infant input'));
    withseat.el.on('click set', function() {
        if (that.type === 'i') {
            that.seat = this.checked;
            that.section.validate();
        }
    });
    birthday.el.on('validate', function(event, date) {
        var type = undefined;
        if (date) {
            var age = that.section.lastFlightDate.age(date);
            type = age < 12 ? (age < 2 ? 'i' : 'c') : 'a';
        }
        if (type !== that.type) {
            that.type = type;
            that.el.find('.bfpo-adult').toggle(type !== 'i');
            that.el.find('.bfpo-infant').toggle(type === 'i');
            that.section.validate();
            booking.form.validate();
        }
    });
    this.controls.push(birthday, withseat);
},
initNationality: function() {
    var nationality = new validator.Select(this.el.find('.bfp-nationality'));
    this.nationality = nationality.select;
    this.controls.push(nationality);
},
initPassport: function() {
    var that = this;
    var passport = new validator.Text(this.el.find('.bfp-passport'), lang.formValidation.passport, function(value) {
        if (/[^\wА-Яа-я. \-№#]/.test(value)) return 'letters';
        if (value.length < 5) return 'empty';
    });
    passport.el.bind('keyup propertychange input paste', function() {
        var value = this.value;
        if (value.length > 9 && value.replace(/\D/g, '').length === 10) {
            that.togglePermanent();
        }
    });
    passport.format = function(value) {
        return $.trim(value.toUpperCase().replace(/[^A-ZА-Я\d]/g, ''));
    };
    this.controls.push(passport);
},
initExpiration: function() {
    var expiration = new validator.Date(this.el.find('.bfp-date').eq(1), lang.formValidation.expiration, function(date) {
        if (date.getTime() < this.time) return 'improper';
    });
    expiration.future = true;
    var permanent = new validator.Checkbox(this.el.find('input[id$="permanent"]'));
    permanent.el.on('click set', function(event) {
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
    this.expiration = expiration;
    this.permanent = permanent;
    this.controls.push(expiration, permanent);
},
togglePermanent: function() {
    if (this.nationality.val() == 170) {
        this.permanent.set(true);
        this.expiration.apply();
    }
},
initBonus: function() {
    var checkbox = this.el.find('input[id$="bonus"]');
    if (checkbox.length === 0) return;
    var exist = new validator.Checkbox(checkbox);
    var row = this.el.find('.bfp-bonus-fields');
    var program = new validator.Select(this.el.find('.bfp-bonus-type'));
    var options = program.select.get(0).options;
    program.values = {};
    for (var i = options.length; i--;) {
        program.values[options[i].value] = true;
    }
    var number = new validator.Text(row.find('.bfp-bonus-number'), lang.formValidation.bonus, function(value) {
        if (/[^\w \-№#]/.test(value)) return 'letters';
        if (value.length < 5) return 'empty';
    });
    number.disabled = true;
    number.format = function(value) {
        return $.trim(value.toUpperCase().replace(/[^A-Z\d]/g, ''));
    };
    exist.el.on('click set', function(event) {
        var disabled = !this.checked;
        row.find('select').prop('disabled', disabled);
        row.toggleClass('latent', disabled);
        number.el.prop('disabled', disabled);
        number.disabled = disabled;
        number.validate();
        number.apply();
        if (event.type !== 'set' && this.checked) {
            number.el.focus();
        }
    });
    this.programIndex = this.controls.length + 1;
    this.controls.push(exist, program, number);
},
toggle: function(ready) {
    this.el.toggleClass('bfp-ready', ready);
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
        this.cash.el.find('.bfcd-radio:checked').trigger('set');
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
        number.el.focus();
    });
    typeParts.mastercard.click(function() {
        toggleType('mastercard');
        number.el.focus();
    });

    var number = new validator.Text($('#bfc-number'), lang.formValidation.cardnumber, function(value) {
        if (/[^\d ]/.test(value)) return 'letters';
        var digits = value.replace(/\D/g, '');
        if (digits.length < 16) return 'empty';
        if (/41{14}|70{14}|5486732058864471|1234561999999999/.test(digits)) {
            return; // тестовые карты
        }
        var sum = 0;
        for (var i = 0; i < 16; i += 2) {
            var n1 = Number(digits.charAt(i)) * 2;
            var n2 = Number(digits.charAt(i + 1));
            if (n1 > 9) n1 -= 9;
            sum += n1 + n2;
        }
        if (sum % 10 !== 0) {
            return 'wrong';
        }
    });
    number.el.bind('keyup propertychange input paste', function() {
        var digits = this.value.replace(/ /g, '');
        if (this.setSelectionRange && / $|\d{5}/.test(this.value)) {
            this.value = digits.replace(/(\d{4})(?=\d)/g, '$1  ');
            setTimeout(function() {
                var field = number.el.get(0);
                var pos = field.value.length;
                field.setSelectionRange(pos, pos);
            }, 0);
        }
        sample.html((digits + '----------------').substring(12, 16).replace(/\D/g, '<span class="bfcn-empty">#</span>'));        
        toggleType(digits ? types[digits.charAt(0)] : undefined);
    });
    number.format = function(value) {
        var digits = $.trim(value).replace(/\D/g, '');
        return digits.replace(/(\d{4})(?=\d)/g, '$1  ');
    };    
    
    // CVV
    var cvv = new validator.Text($('#bc-cvv'), lang.formValidation.cvc, function(value) {
        if (/\D/.test(value)) return 'letters';
        if (value.length < 3) return 'empty';
    });

    // Имя владельца
    var name = new validator.Text($('#bfc-name'), lang.formValidation.cardholder, function(value) {
        if (/[^A-Za-z\- .']/.test(value)) return 'letters';
    });
    name.format = function(value) {
        return $.trim(value).toUpperCase();
    };

    // Срок действтия
    var date = new validator.CardDate(context.find('.bfc-date'), lang.formValidation.cardexp, function(value) {
        if (/[^A-Za-z\- .']/.test(value)) return 'letters';
    });

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
