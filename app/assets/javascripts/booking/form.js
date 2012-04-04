/* Booking */
var booking = {
init: function() {
    var that = this;
    this.el = $('#booking');
    this.header = this.el.find('.booking-header');
    this.el.delegate('.stop-booking', 'click', function() {
        that.hide();
    });
},
show: function() {
    var offset = this.variant ? (this.variant.offset().top - $(window).scrollTop()) : 0;
    $('#header, #wrapper, #footer').hide();
    this.el.removeClass('latent');
    this.el.find('.bh-title').html(results.title.html());
    this.el.find('.bh-placeholder').height(this.header.height());
    search.history.toggle(false);
    fixedBlocks.disabled = true;
    $(window).scrollTop(offset ? (this.el.find('.booking-frame').offset().top - offset) : 0);
    pageurl.update('booking', this.key);
    pageurl.title('бронирование авиабилета ' + results.title.attr('data-title'));
    this.abort();
},
hide: function() {
    var offset = this.el.find('.booking-frame').offset().top - $(window).scrollTop();
    this.el.addClass('latent');
    $('#header, #wrapper, #footer').show();
    $(window).scrollTop(this.variant ? (this.variant.offset().top - offset) : 0);
    pageurl.update('booking', undefined);
    pageurl.title('авиабилеты ' + results.title.attr('data-title'));
    fixedBlocks.disabled = false;
    fixedBlocks.toggle(true);    
    search.history.toggle(search.history.active);
},
abort: function() {
    if (this.request && this.request.abort) {
        this.request.abort();
        delete this.request;
    }
    if (this.prebooking) {
        this.prebooking.closest('.offer').removeClass('prebooking')
        this.prebooking.remove();
        delete this.prebooking;
    }
},
prebook: function(variant) {
    var that = this;
    var vid = '&variant_id=' + results.selectedTab + '-' + variant.attr('data-index');
    this.abort();
    this.variant = variant;
    this.prebooking = $('<div class="prebooking-state"><h4 class="progress">Проверяем доступность мест</h4></div>');
    this.prebooking.appendTo(variant.closest('.offer').addClass('prebooking'));
    this.request = $.ajax({
        url: '/booking/preliminary_booking?' + variant.attr('data-booking') + vid,
        success: function(result) {
            if (result && result.success) {
                that.load(result.number);
            } else {
                that.failed();
            }
        },
        error: function() {
            that.failed();
        },
        timeout: 60000
    });
    if (variant.closest('.offer').hasClass('collapsed')) {
        $('.expand', variant).click();
    }
    var st = variant.offset().top + variant.height() - Math.round($(window).height() / 2);
    if (st > $(window).scrollTop()) {
        $.animateScrollTop(st);
    }
},
failed: function() {
    var content = '<h4>К сожалению, по этому тарифу места закончились.<br><span class="link pbf-reload">Повторите поиск</span> или выберите другой вариант.</h4><p><span class="link pbf-hint">Почему так бывает?</span></p>';
    var message = 'Так иногда бывает, потому что авиакомпания не&nbsp;может подтвердить наличие мест на&nbsp;этот рейс по&nbsp;этому тарифу. К&nbsp;сожалению, от&nbsp;нас это не&nbsp;зависит. Спасибо за&nbsp;понимание.';
    this.prebooking.html(content);
    this.prebooking.find('.pbf-hint').click(function(event) {
        hint.show(event, message);
    });
    this.prebooking.find('.pbf-reload').click(function(event) {
        results.reload();
    });
    if (window._gaq) {
        _gaq.push(['_trackEvent', 'Бронирование', 'Невозможно выбрать вариант']);
    }
},
getVariant: function() {
    this.variant.closest('.offer').removeClass('collapsed').addClass('expanded');
    this.el.find('.booking-variant').html('').append(this.variant.clone());
},
load: function(number) {
    var that = this;
    this.request = $.ajax({
        url: '/booking/',
        method: 'GET',
        data: {number: number},
        success: function(result) {
            that.key = number;
            that.el.find('.booking-content').html(result);
            if (that.variant && that.prebooking) {
                if (that.compare()) {
                    that.show();
                }
            } else {
                that.waiting = true;
            }
            if (that.el.find('.booking-corporate').length === 0) {
                that.activate();
            } else {
                that.form.el = that.el.find('.booking-corporate');
            }
        },
        error: function() {
            that.failed();
        }
    });
},
compare: function() {
    var source = this.el.find('.booking-price');
    var bp = parseInt(source.find('.sum').attr('data-value'), 10);
    var vp = parseInt(this.variant.find('.book .sum').attr('data-value'), 10);
    if (bp != vp) {
        var offer = this.variant.closest('.offer');
        offer.find('.offer-variant').each(function() {
            $(this).find('.book .sum').replaceWith(source.find('.sum').clone());
            $(this).find('.cost dl').replaceWith(source.find('.cost dl').clone());
        });
        if (offer.hasClass('cheap-offer')) {
            offer.find('.cost dl').prepend('<dd>Всего </dd>');
        }
        var self = this;
        var template = '<h5>Цена этого варианта изменилась: стало <strong>{type} на {value}</strong> (<span class="link">почему?</span>)</h5>';
        this.prebooking.addClass('changed-price').html(template.supplant({
            type: bp > vp ? 'дороже' : 'дешевле',
            value: Math.abs(bp - vp).inflect('рубль', 'рубля',  'рублей')
        }));
        this.prebooking.append('<p><a class="a-button continue" href="#">Продолжить бронировать</a> или <span class="link cancel">выбрать другой вариант</span></p>');
        this.prebooking.find('h5 .link').click(function(event) {
            hint.show(event, 'Так иногда бывает, потому что авиакомпания изменяет цену на&nbsp;этот тариф. Цена может меняться как в&nbsp;большую, так и&nbsp;в&nbsp;меньшую сторону. К&nbsp;сожалению, от&nbsp;нас это не&nbsp;зависит. Спасибо за&nbsp;понимание.');
        });
        this.prebooking.find('.cancel').click(function(event) {
            self.abort();
        });
        this.prebooking.find('.continue').click(function(event) {
            event.preventDefault();
            self.show();
        });
        this.getVariant();
        return false;
    } else {
        this.getVariant();    
        return true;
    }
},
activate: function() {
    var context = this.el.find('.booking-content');
    this.form.init(context);
    this.farerules.init(context);
}
};

/* Booking form */
booking.form = {
init: function(context) {
    var that = this;
    this.el = context.find('.booking-form');

    // Всплывающие подсказки
    this.el.delegate('.hint', 'click', function(event) {
        event.preventDefault();
        hint.show(event, $(this).parent().find('.htext').html());
    });
    
    // Список неправильно заполненных полей
    this.el.find('.be-list').delegate('.link', 'click', function() {
        var control = $('#' + $(this).attr('data-field'));
        var st = control.closest(':visible').offset().top - booking.header.height() - 35;
        $.animateScrollTop(Math.min(st, $(window).scrollTop()), function() {
            control.focus();
        });
    });
    
    // 3DSecure
    this.el.delegate('.tds-submit .a-button', 'click', function(event) {
        event.preventDefault();
        $(this).closest('.result').find('form').submit();
    });
    
    // Кнопка
    this.submit = this.el.find('.booking-submit');
    this.button = this.submit.find('.a-button');

    // Отправка формы
    this.el.children('form').submit(function(event) {
        event.preventDefault();
        if (that.button.hasClass('a-button-ready')) {
            that.send($(this).attr('action'), $(this).serialize());
        }
    });

    // Имена
    if (constants.names === undefined) {
        constants.names = {m: '', f: ''};
    } else if (!constants.names.ready) {
        constants.names['m'] = ' ' + constants.names['m'].toLowerCase() + ',';
        constants.names['f'] = ' ' + constants.names['f'].toLowerCase() + ',';
        constants.names.ready = true;
    }
    
    // Проверка формы
    this.sections = [];
    this.el.find('.booking-person').each(function() {
        that.initPerson($(this));
    });
    var card = this.el.find('.booking-card');
    var cash = this.el.find('.booking-cash');
    var cardSection = this.initCard(card);
    if (cash.length) {
        var cashSection = this.initCash(cash);
        var toggleCash = function(mode) {
            card.toggleClass('latent', mode);
            cash.toggleClass('latent', !mode);
            card.find('input').each(function() {
                this.disabled = mode;
            });
            cash.find('input, textarea').each(function() {
                this.disabled = !mode;
            });
            cardSection.disabled = mode;
            cashSection.disabled = !mode;
            that.validate();
            $('#booking-payment-type').val(mode ? cash.find('.bc-delivery input:checked').attr('value') : 'card');
            that.el.find('.payment-card').toggleClass('latent', mode);
            that.el.find('.payment-cash').toggleClass('latent', !mode);
        };
        card.find('.section-tabs .link').click(function() {
            toggleCash(true);
        });
        cash.find('.section-tabs .link').click(function() {
            toggleCash(false);
        });
        toggleCash(false);
    } else {
        card.find('.section-tabs .link').closest('li').addClass('disabled').html('Этот билет возможно оплатить только банковской картой');
    }
    this.initContacts(this.el.find('.booking-contacts'));    
    this.validate(true);

},
send: function(url, data) {
    var that = this;
    this.el.find('.result').remove();
    this.el.find('.booking-disclaimer').hide();
    this.el.find('.booking-errors').hide();
    $.ajax({
        url: url,
        data: data,
        type: 'POST',
        success: function(result) {
            if (typeof result === 'string' && result.length) {
                that.el.append(result);
                that.process();
            } else if (result && result.errors) {
                var items = that.parse(result.errors);
                that.el.find('.be-list').html(items.join(''));
                that.el.find('.booking-errors').show();            
            } else {
                that.error(result && result.exception && result.exception.message);
            }
            that.button.addClass('a-button-ready').attr('value', that.button.attr('data-text'));
            that.submit.removeClass('sending');
        },
        error: function() {
            that.error();
            that.button.addClass('a-button-ready').attr('value', that.button.attr('data-text'));
            that.submit.removeClass('sending');
        },
        timeout: 90000
    });
    this.button.removeClass('a-button-ready').attr('value', 'Секундочку…');
    this.submit.addClass('sending');
},
process: function() {
    var result = this.el.find('.result');
    switch (result.attr('data-type')) {
    case 'success':
        this.submit.addClass('latent');
        this.track(result);
        break;
    case '3dsecure':
        this.submit.addClass('latent');
        break;
    case 'fail':    
        this.button.addClass('a-button-ready');
        break;
    case 'newprice':
        this.newprice(result);
        break;
    }
},
track: function(result) {
    if (window._gaq) {
        var price = booking.el.find('.booking-content .booking-price .sum').attr('data-value');
        _gaq.push(['_trackPageview', '/booking/success']);
        _gaq.push(['_addTrans', result.find('.pnr').text(), '', price]);
        _gaq.push(['_trackTrans']);
    }
    if (window.yaCounter5324671) {
        yaCounter5324671.hit('/booking/success');
    }
},
newprice: function(context) {
    var that = this;
    var cp = Number(this.el.parent().find('.booking-price .sum').attr('data-value'));
    var np = Number(context.attr('data-price'));
    var template = '{type} на {value}';
    context.find('.bnp-diff').html(template.supplant({
        type: np > cp ? 'дороже' : 'дешевле',
        value: Math.abs(np - cp).inflect('рубль', 'рубля',  'рублей')
    }));
    var delivery = $('#bcpt-delivery').prop('checked');
    context.find('.bc-address, .bcb-delivery').toggle(delivery);
    context.find('.bc-contacts, .bcb-nodelivery').toggle(!delivery);
    this.el.find('.booking-card .bc-bill-short').after(context.find('.bc-bill-short')).remove();
    this.el.find('.booking-cash .bc-bill').after(context.find('.bc-bill')).remove();
    this.submit.addClass('latent');
    context.removeClass('latent');
    context.find('.continue').click(function(event) {
        event.preventDefault();
        that.el.children('form').submit();
        that.submit.removeClass('latent');
    });
    context.find('.cancel').click(function() {
        booking.hide();
    });
},
parse: function(errors) {
    var items = [];
    var carderror = false;
    for (var eid in errors) {
        var ftitle = eid;
        if (ftitle.search(/card\[(?:number|type)\]/i) !== -1) {
            carderror = true;
        } else if (ftitle.search('birthday') !== -1) {
            ftitle = ftitle.replace(/person\[(\d)\]\[birthday\]/i, function(s, n) {
                var num = constants.numbers.ordinaldat[parseInt(n, 10)];
                var ptitle = this.el.find('.booking-person').length > 1 ? (num.charAt(0).toUpperCase() + num.substring(1) + ' пассажиру') : 'Пассажиру';
                return '<span class="link" data-field="bp-' + n + '-byear">' + ptitle + '</span>';
            });
            items.push('<li>' + ftitle + ' ' + errors[eid] + '</li>');
        } else if (ftitle.search('passport') !== -1) {
            var index = parseInt(ftitle.match(/person\[(\d)\]\[passport\]/)[1], 10);
            var str = 'Введён неправильный <span class="link" data-field="booking-person-' + index + '-passport">номер документа</span>';
            if (this.el.find('.booking-person').length > 1) {
                str += ' ' + constants.numbers.ordinalgen[index] + ' пассажира';
            }
            items.push('<li>' + str + '</li>');
        } else {
            items.push('<li>' + ftitle + ' ' + errors[eid] + '</li>');
        }
    }
    if (carderror) {
        items.push('<li>Введён неправильный <span class="link" data-field="bc-num1">номер банковской карты</span></li>');
    }
    return items;
},
error: function(text) {
    var block = $('<div class="result"></div>');
    block.append('<p class="fail"><strong>Упс…</strong> ' + (text || 'Что-то пошло не так.') + '</p>');
    block.append('<p class="tip">Попробуйте снова или узнайте, <a target="_blank" href="/about/#payment">какими ещё способами</a> можно купить у нас билет.</p>');
    this.el.append(block);
},
validate: function(full) {
    clearTimeout(this.vtimer);
    var errors = [];
    for (var s = 0, sm = this.sections.length; s < sm; s++) {
        var section = this.sections[s];
        if (section.disabled) {
            continue;
        }
        var valid = true;
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
    this.button.toggleClass('a-button-ready', errors.length === 0);
    if (errors.length) {
        this.el.find('.be-list').html('<li>' + errors.slice(0, 3).join('</li><li>') + '</li>');
        this.el.find('.booking-errors').show();
    } else {
        this.el.find('.booking-errors').hide();
        this.el.find('.be-list').html('');
    }
}
};

/* Person fields */
booking.form.initPerson = function(el) {
    var fname = validator.name(el.find('input[id$="first_name"]'), {
        empty: 'Не указано {имя пассажира}',
        short: '{Имя пассажира} нужно ввести полностью',
        latin: '{Имя пассажира} нужно ввести латинскими буквами',
        space: '{Имя пассажира} нужно ввести без пробелов'
    });
    var lname = validator.name(el.find('input[id$="last_name"]'), {
        empty: 'Не указана {фамилия пассажира}',
        short: '{Фамилию пассажира} нужно ввести полностью',
        latin: '{Фамилию пассажира} нужно ввести латинскими буквами',
        space: '{Фамилию пассажира} нужно ввести без пробелов'
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
    fname.el.add(lname.el).change(function() {
        var fn = fname.el.val();
        var ln = lname.el.val();
        if (fn && ln && getGender(ln) && !getGender(fn)) {
            orderWarning.fadeIn(150);
        } else {
            orderWarning.fadeOut(150);
        }
    });
    var orderWarning = el.find('.nameorder-warning');
    orderWarning.find('.link').click(function() {
        orderWarning.fadeOut(150);
        if ($(this).hasClass('nameorder-replace')) {
            var fn = fname.el.val();
            var ln = lname.el.val();
            fname.el.val(ln).change();
            lname.el.val(fn).change();
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
    var toggleExp = function() {
        pdate.disabled = docexp.get(0).checked;
        docexp.closest('td').toggleClass('disabled', pdate.disabled);
        pdate.el.each(function() {
            this.disabled = pdate.disabled;
        });
        pdate.validate();
    };
    var docexp = el.find('.bp-docexp input:checkbox').click(toggleExp);
    var nationality = el.find('.nationality').change(function() {
        passport.russian = $(this).val() === '170';
    }).trigger('change');
    passport.el.bind('keyup propertychange input', function() {
        var value = $(this).val().replace(/\D/g, '');
        var noexp = docexp.get(0);
        if (passport.russian && !noexp.checked && value.length === 10) {
            noexp.checked = true;
            toggleExp();
        }
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

/* Card fields */
booking.form.initCard = function(el) {
    var cardnumber = validator.cardnumber(el.find('.bcn-fields input'), {
        empty: 'Не указан {номер банковской карты}',
        letters: 'В {номере банковской карты} можно использовать только цифры'
    });
    var numsample = $('#bc-num-sample');
    cardnumber.el.last().bind('keyup propertychange input change', function() {
        var v = $(this).val(), s = [], digits = /\d/;
        for (var i = 0; i < 4; i++) {
            var c = v.charAt(i);
            s[i] = digits.test(c) ? c : '<span class="empty">#</span>';
        }
        numsample.html(s.join(''));
    });
    var typeor = el.find('.bc-type-or');
    var toggleCardType = function(type) {
        visa.toggle(type !== 'mastercard');
        mastercard.toggle(type !== 'visa');
        typeor.toggle(type === undefined);
    };
    var types = {
        '4': 'visa',
        '3': 'mastercard',
        '5': 'mastercard',
        '6': 'mastercard'
    };
    var visa = el.find('.bc-visa').click(function() {
        toggleCardType('visa');
        cardnumber.el.first().focus();
    });
    var mastercard = el.find('.bc-master').click(function() {
        toggleCardType('mastercard');
        cardnumber.el.first().focus();
    });
    cardnumber.el.first().bind('keyup propertychange input', function() {
        toggleCardType(this.value ? types[this.value.charAt(0)] : undefined);
    });
    var cardcvv = validator.cardcvv($('#bc-cvv'), {
        empty: 'Не указан трёхзначный {CVV/CVC код} банковской карты',
        letters: '{CVV/CVC код} банковской карты нужно ввести цифрами',
    });
    var cardname = validator.cardname($('#bc-name'), {
        empty: 'Не указано {имя владельца} банковской карты',
        latin: '{Имя владельца} банковской карты нужно ввести латинскими буквами'
    });
    var cardexp = validator.cardexp(el.find('.bc-exp input'), {
        empty: 'Не указан {срок действия} банковской карты',
        letters: '{Cрок действия} банковской карты нужно ввести цифрами в формате дд/гг',
        month: 'Месяц в {сроке действия} банковской карты должене быть числом от 1 до 12',
        past: 'Указан истекший {срок действия} банковской карты'
    });
    return this.sections[this.sections.push({
        el: el,
        items: [cardnumber, cardname, cardexp, cardcvv]
    }) - 1];
};

/* Cash fields */
booking.form.initCash = function(el) {
    var address = validator.text($('#bc-address'), {
        empty: 'Не указан {адрес доставки}'
    });
    var toggleDelivery = function(mode) {
        el.find('.bc-address, .bcb-delivery').toggle(mode);
        el.find('.bc-contacts, .bcb-nodelivery').toggle(!mode);
        address.el.get(0).disabled = !mode;
        address.disabled = !mode;
    };
    this.el.find('.bc-delivery input').click(function() {
        var value = $(this).attr('value');
        $('#booking-payment-type').val(value);
        toggleDelivery(value == 'delivery');
        address.validate();
    }).get(0).checked = true;
    toggleDelivery(true);
    address.validate();
    return this.sections[this.sections.push({
        el: el,
        items: [address]
    }) - 1];
};

/* Contacts fields */
booking.form.initContacts = function(el) {
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

/* Farerules */
booking.farerules = {
init: function(context) {
    var that = this;
    this.selfhide = function(event) {
        if (event.type == 'click' || event.which == 27) {
            that.popup.hide();
            $('body').unbind('click keydown', that.selfhide);
        }
    };
    this.popup = context.find('.farerules').click(function(event) {
        event.stopPropagation();
    });
    this.popup.find('.close').click(this.selfhide);
    this.popup.find('.fgrus').click(function() {
        var rus = $(this).addClass('g-none');
        var eng = rus.siblings('.fgeng');
        that.translate(rus, eng);
    });
    this.popup.find('.fgeng').click(function() {
        var eng = $(this).addClass('g-none');
        var rus = eng.siblings('.fgrus').removeClass('g-none');
        rus.closest('.fgroup').find('pre').html(eng.data('text'));
    });
    context.find('.farerules-link').click(function(event) {
        event.preventDefault();
        that.show();
    });
},
show: function() {
    var self = this;
    this.popup.css('top', 0).show();
    var fh = this.popup.outerHeight();
    var ft = this.popup.offset().top;
    var ws = $(window).scrollTop();
    var wh = $(window).height();
    this.popup.css('top', Math.min(ws + (wh - fh) / 2, ws + wh - fh - 50) - ft);
    setTimeout(function() {
        $('body').bind('click keydown', self.selfhide);
    }, 20);
},
translate: function(rus, eng) {
    var text = rus.closest('.fgroup').find('pre');
    var loading = rus.siblings('.fgloading');
    if (!eng.data('text')) {
        eng.data('text', text.html());
    }
    if (rus.data('text')) {
        text.html(rus.data('text'));
        eng.removeClass('g-none');
    } else {
        loading.removeClass('g-none');
        var s = text.text();
        if (s.length > 1838) {
            s = s.substring(0, 1835);
            s = s.substring(0, s.lastIndexOf('\n') + 1) + '…';
        }
        $.ajax({
            url: 'https://ajax.googleapis.com/ajax/services/language/translate',
            dataType: 'jsonp',
            data: {
                q: s,
                v: '1.0',
                langpair: 'en|ru',
                format: 'text'
            },
            success: function(response) {
                var data = response.responseData;
                loading.addClass('g-none');
                if (data && data.translatedText) {
                    text.html(data.translatedText);
                    eng.removeClass('g-none');
                    rus.data('text', data.translatedText);
                } else {
                    rus.removeClass('g-none');
                }
            },
            error: function() {
                loading.addClass('g-none');
                rus.removeClass('g-none');
            },
            timeout: 20000
        });
    }
}
};
