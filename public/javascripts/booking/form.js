/* Booking form */
app.booking = {
init: function() {
    var self = this;
    /*var sections = $('.section[onclick]', this.el);
    this.steps = $.map(sections, function(el, i) {
        return new (app[el.onclick()])(el, i);
    });*/
    
    // Проверка формы
    this.sections = [];
    this.el.find('.booking-person').each(function() {
        self.initPerson($(this));
    });
    this.initCard(this.el.find('.booking-card'));
    this.initContacts(this.el.find('.booking-contacts'));
    this.validate(true);

    // Отправка формы
    $('form', this.el).submit(function(event) {
        event.preventDefault();
        if (!self.submit.hasClass('a-button-ready')) return;
        var data = $(this).serialize();
        var rcontrol = self.submit.removeClass('a-button-ready').closest('.control');
        var processError = function(text) {
            self.el.find('.book-s').addClass('book-retry');
            self.el.append('<div class="result"><p class="fail"><strong>Упс…</strong> ' + (text || 'Что-то пошло не так.') + '</p><p class="tip">Попробуйте снова или узнайте <a target="_blank" href="/about/#payment">какими ещё способами</a> можно купить у нас билет.</p></div>');
            self.submit.addClass('a-button-ready');
        };
        self.el.find('.result').remove();
        self.el.find('.book-s').removeClass('book-retry');        
        $.ajax({
            url: $(this).attr('action'),
            data: data,
            type: 'POST',
            success: function(s) {
                if (typeof s === 'string' && s.length) {
                    var result = $(s).appendTo(self.el);
                    var rtype = result.attr('data-type');
                    self.el.find('.book-s').addClass(rtype === 'fail' ? 'book-retry' : 'g-none');
                    if (rtype === 'success') {
                        if (window._gaq) {
                            _gaq.push(['_trackPageview', '/#' + pageurl.summary + ':success']);
                            _gaq.push(['_addTrans', result.find('.pnr').text(), '', self.el.find('.booking-price .sum').attr('data-value')]);
                            _gaq.push(['_trackTrans']);
                        }
                        if (window.yaCounter5324671) {
                            yaCounter5324671.hit('/#' + pageurl.summary + ':success');
                        }
                    }
                } else if (s && s.errors) {
                    var items = [];
                    for (var eid in s.errors) {
                        var ftitle = eid;
                        if (ftitle.search(/card\[number\]/i) !== -1) {
                            items.push('<li>введён неправильный <a href="#" data-id="bc-num1"><u>номер карты</u></a></li>');
                        } else if (ftitle.search(/card\[type\]/i) === -1) {
                            ftitle = ftitle.replace(/person\[(\d)\]\[birthday\]/i, function(s, n) {
                                return '<a href="#" data-id="book-p-' + n + '-birth"><u>' + constants.numbers.ordinaldat[parseInt(n, 10)] + ' пассажиру</u></a>';
                            });
                            items.push('<li>' + ftitle + ' ' + s.errors[eid] + '</li>');
                        }
                    }
                    self.submit.addClass('a-button-ready');
                    self.el.find('.blocker').show().find('.b-pseudo').html(items.join(''));
                    self.el.removeClass('book-retry');
                } else {
                    processError(s && s.exception && s.exception.message);
                }
                rcontrol.removeClass('sending');
            },
            error: function() {
                processError();
                rcontrol.removeClass('sending');
            },
            timeout: 90000
        });
        rcontrol.addClass('sending');
    });
    this.submit = $('.book-s .a-button', this.el);
    /*for (var i = this.steps.length; i--;) {
        this.steps[i].change();
    }*/
    
    // Повторная попытка
    this.el.delegate('a.retry', 'click', function(event) {
        event.preventDefault();
        $(this).closest('.result').remove();
        $('.book-s', self.el).removeClass('g-none');
        pageurl.update('payment', undefined);
    });

    // Всплывающие подсказки
    this.el.delegate('.hint', 'click', function(event) {
        event.preventDefault();
        hint.show(event, $(this).parent().find('.htext').html());
    });

    // Список неправильно заполненных полей
    $('.blocker', this.el).delegate('a', 'click', function(event) {
        event.preventDefault();
        var control = $('#' + $(this).attr('data-id'));
        var st = control.closest(':visible').offset().top - results.header.height() - 25;
        $.animateScrollTop(Math.min(st, $(window).scrollTop()), function() {
            control.focus();
        });
    });
    /*
    sections.bind('setready', function() {
        var ready = true, errors = [];
        for (var i = 0, im = self.steps.length; i < im; i++) {
            var step = self.steps[i];
            if (!step.ready) {
                ready = false;
                if (step.state) {
                    errors = errors.concat(step.state);
                }
            }
        }
        self.submit.toggleClass('a-button-ready', ready);
        var blocker = $('.blocker', self.el).toggle(!ready);
        if (!ready && errors.length) {
            $('.b-pseudo', blocker).html('<li>' + errors.slice(0, 3).join('</li><li>') + '</li>');
        }
    });
    sections.eq(0).trigger('setready');
    */
    
    // Правила тарифов
    this.farerules.init(this.el);

    // Прекращение бронирования
    results.filters.el.hide();
    $('<div class="stop-booking-panel"><span class="link stop-booking">Вернуться к выбору вариантов</span></div>').appendTo(results.header.find('.rcontent')).find('.stop-booking').click(this.selfhide);
    this.el.delegate('.stop-booking', 'click', this.selfhide);
    
    // 3DSecure
    this.el.delegate('.tds-submit .a-button', 'click', function(event) {
        event.preventDefault();
        $(this).closest('.result').find('form').submit();
    });

    // Имена
    if (constants.names === undefined) {
        constants.names = {m: '', f: ''};
    } else if (!constants.names.ready) {
        constants.names['m'] = ' ' + constants.names['m'].toLowerCase() + ',';
        constants.names['f'] = ' ' + constants.names['f'].toLowerCase() + ',';
        constants.names.ready = true;
    }

    // Заголовок страницы
    pageurl.title('бронирование авиабилета ' + results.title.attr('data-title'));

},
show: function(variant) {
    var self = this;
    if (variant) {
        if (this.el) this.hide();
        this.variant = variant;
        this.offer = variant.closest('.offer');
        this.el = $('<div class="booking"></div>').appendTo(this.offer);
        if (this.offer.hasClass('collapsed')) {
            $('.expand', variant).click();
        }
    } else {
        this.offer.removeClass('collapsed').addClass('expanded');
    }
    this.offersTab = results.selectedTab;
    this.selfhide = function(event) {
        event.preventDefault();
        self.hide();
    };
    var link = $('<a class="stop-booking" href="#">Вернуться к выбору вариантов</a>').click(this.selfhide).prependTo(this.offer);
    if (this.offer.parent('#offers-matrix').length) {
        link.css('top', this.offer.find('.offer-prices').height());
    }
    this.offer.addClass('active-booking');
},
hide: function() {
    results.filters.el.addClass('hidden').show();
    results.header.find('.stop-booking-panel').remove();
    this.offer.find('.stop-booking').remove();
    this.unfasten();
    this.offer.removeClass('active-booking');
    this.el.remove();
    delete(this.el);
    delete(this.offer);
    delete(this.variant);
    pageurl.update('booking', undefined);
    pageurl.title('авиабилеты ' + results.title.attr('data-title'));    
},
error: function() {
    var message = $('<div class="booking-state"><h4>В данный момент невозможно выбрать этот вариант</h4><p><span class="link">Почему?</span></p></div>');
    message.find('.link').click(function(event) {
        hint.show(event, 'Так иногда бывает, потому что авиакомпания не&nbsp;может подтвердить наличие мест на&nbsp;этот рейс по&nbsp;этому тарифу. К&nbsp;сожалению, от&nbsp;нас это не&nbsp;зависит. Спасибо за&nbsp;понимание.');
    });
    this.el.html('').append(message);
},
book: function(variant) {
    var self = this;
    this.el.html('<div class="booking-state"><div class="progress"></div><h4>Проверяем доступность</h4></div>');
    var vid = '&variant_id=' + [self.offersTab, this.variant.attr('data-index')].join('-');
    $.ajax({
        url: "/booking/preliminary_booking?" + variant.attr('data-booking') + vid,
        success: function(s) {
            $('#offers-tabs').trigger('set', self.offersTab);
            if (s && s.success) {
                self.load(s.number);
                pageurl.update('booking', s.number);
            } else {
                self.error();
            }
        },
        error: function() {
            self.error();
        },
        timeout: 60000
    });
    var w = $(window), offset = this.el.offset().top - w.height();
    if (offset > w.scrollTop()) {
        $.animateScrollTop(offset + 250);
    }
},
load: function(number) {
    var self = this;
    $.get('/booking/', {number: number}, function(s) {
        self.el = $(s).replaceAll(self.el);
        if (self.el.attr('data-variant') && self.variant && self.comparePrice()) {
            self.fasten(self.offer);
            self.init();
        }
    });
},
comparePrice: function() {
    var vp = parseInt(this.variant.find('.book .sum').attr('data-value'), 10);
    var bp = parseInt(this.el.find('.booking-price .sum').attr('data-value'), 10);
    if (bp != vp) {
        var source = this.el.find('.booking-price');
        this.variant.closest('.offer').find('.offer-variant').each(function() {
            $(this).find('.book .sum').replaceWith(source.find('.sum').clone());
            $(this).find('.cost dl').replaceWith(source.find('.cost dl').clone());
        });
        var block = $('<div class="diff-price"></div>');
        var template = '<h5>Цена этого варианта изменилась: стало <strong>{type} на {value}</strong> (<span class="link">почему?</span>)</h5>';
        block.append(template.supplant({
            type: bp > vp ? 'дороже' : 'дешевле',
            value: Math.abs(bp - vp).inflect('рубль', 'рубля',  'рублей')
        })).append('<p><a class="a-button continue" href="#">Продолжить бронировать</a> или <a class="cancel" href="#">выбрать другой вариант</span></p>');
        var self = this;
        block.find('.link').click(function(event) {
            hint.show(event, 'Так иногда бывает, потому что авиакомпания изменяет цену на&nbsp;этот тариф. Цена может меняться как в&nbsp;большую, так и&nbsp;в&nbsp;меньшую сторону. К&nbsp;сожалению, от&nbsp;нас это не&nbsp;зависит. Спасибо за&nbsp;понимание.');
        });
        block.find('.cancel').click(function(event) {
            event.preventDefault();
            $(this).closest('.diff-price').remove();
            self.hide();
        });
        block.find('.continue').click(function(event) {
            event.preventDefault();
            $(this).closest('.diff-price').remove();
            self.el.removeClass('g-none');
            self.fasten(self.offer);
            self.init();                      
        });
        this.el.before(block);
        return false;
    } else {
        this.el.removeClass('g-none');
        return true;
    }
},
fasten: function(offer) {
    if (browser.scanty) return;
    var wrapper = $('#wrapper');
    var ot = offer.offset().top, ob = wrapper.height() - ot - offer.height();
    var cst = $(window).scrollTop();
    wrapper.addClass('cropped');
    $('#results-header').addClass('fixed');
    $('#header').hide();
    var mt = results.title.outerHeight() + 50, mb = 40;
    $('#canvas').css({
        'margin-top': mt - ot - ob + mb,
        'top': ob - mb
    });
    this.dst = ot - mt;
    fixedBlocks.disabled = true;
    $(window).scrollTop(cst - this.dst);
},
unfasten: function() {
    var wrapper = $('#wrapper');
    if (!browser.scanty && wrapper.hasClass('cropped')) {
        $('#header').show();
        $('#canvas').css({
            'margin-top': 0,
            'top': 0
        });
        wrapper.removeClass('cropped');
        $(window).scrollTop($(window).scrollTop() + this.dst);
        fixedBlocks.disabled = false;
        fixedBlocks.toggle(true);
    }
    this.dstop = 0;
}
};

/* Farerules */
app.booking.farerules = {
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
    this.popup.css('top', 0).show();
    var fh = this.popup.outerHeight();
    var ft = this.popup.offset().top;
    var ws = $(window).scrollTop();
    var wh = $(window).height();
    this.popup.css('top', Math.min(ws + (wh - fh) / 2, ws + wh - fh - 50) - ft);
    setTimeout(function() {
        $('body').bind('click keydown', this.selfhide);
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
        $.ajax({
            url: 'https://ajax.googleapis.com/ajax/services/language/translate',
            dataType: 'jsonp',
            data: {
                q : text.html().substr(0, 5000),
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
