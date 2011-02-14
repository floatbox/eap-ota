/* Booking form */
app.booking = {
init: function() {
    var self = this;
    var sections = $('.section[onclick]', this.el);
    this.steps = $.map(sections, function(el, i) {
        return new (app[el.onclick()])(el, i);
    });

    // Отправка формы
    $('form', this.el).submit(function(event) {
        event.preventDefault();
        if (!self.submit.hasClass('a-button-ready')) return;
        var data = $(this).serialize();
        var rcontrol = self.submit.addClass('a-button-ready').closest('.control');
        var processError = function(text) {
            self.el.find('.book-s').addClass('book-retry');
            self.el.append('<div class="result"><p class="fail"><strong>Упс…</strong> ' + (text || 'Что-то пошло не так.') + '</p><p class="tip">Попробуйте снова или узнайте <a target="_blank" href="/about/#payment">какими ещё способами</a> можно купить у нас билет.</p></div>');
        };
        $.ajax({
            url: $(this).attr('action'),
            data: data,
            success: function(s) {
                self.el.find('.result').remove();
                if (typeof s === 'string' && s.length) {
                    var result = $(s).appendTo(self.el);
                    var rtype = result.attr('data-type');
                    self.el.find('.book-s').addClass(rtype === 'fail' ? 'book-retry' : 'g-none');
                    if (rtype === 'success' && window._gaq) {
                        _gaq.push(['_trackPageview', '/#' + pageurl.summary + ':success']);
                        _gaq.push(['_addTrans', result.find('.pnr').text(), self.el.find('.booking-price .sum').attr('data-value')]);
                        _gaq.push(['_trackTrans']);
                    }
                } else if (s && s.errors) {
                    var items = [];
                    for (var eid in s.errors) {
                        var ftitle = eid;
                        if (ftitle.search(/card\[number|type\]/i) > -1) {
                            items.push('<li>введён неправильный <a href="#" data-id="bc-num1"><u>номер карты</u></a></li>');
                        } else {
                            ftitle = ftitle.replace(/person\[(\d)\]\[birthday\]/i, function(s, n) {
                                return '<a href="#" data-id="book-p-' + n + '-birth"><u>' + constants.numbers.ordinaldat[parseInt(n, 10)] + ' пассажиру</u></a>';
                            });
                            items.push('<li>' + ftitle + ' ' + s.errors[eid] + '</li>');
                        }
                    }
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
            timeout: 45000
        });
        rcontrol.addClass('sending');
    });
    this.submit = $('.book-s .a-button', this.el);
    for (var i = this.steps.length; i--;) {
        this.steps[i].change();
    }
    
    // Повторная попытка
    this.el.delegate('a.retry', 'click', function(event) {
        event.preventDefault();
        $(this).closest('.result').remove();
        $('.book-s', self.el).removeClass('g-none');
        pageurl.update('payment', undefined);
    });

    // Всплывающие подсказки
    this.el.delegate('.b-hint', 'click', function(event) {
        event.preventDefault();
        hint.show(event, $(this).next('p').html());
    });

    // Список неправильно заполненных полей
    $('.blocker', this.el).delegate('a', 'click', function(event) {
        event.preventDefault();
        var control = $('#' + $(this).attr('data-id'));
        $(window).scrollTop(control.closest(':visible').offset().top - 50);
        control.focus();
    });
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
    
    // Правила тарифов
    var frPopup = this.el.find('.farerules').click(function(event) {
        event.stopPropagation();
    });
    var frHide = function(event) {
        if (event.type == 'click' || event.which == 27) {
            frPopup.hide();
            $('body').unbind('click keydown', frHide);
        }
    };
    frPopup.find('.close').click(frHide);
    frPopup.find('.fgrus').click(function() {
        var rus = $(this).addClass('g-none'), eng = rus.siblings('.fgeng');
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
    });
    frPopup.find('.fgeng').click(function() {
        var eng = $(this).addClass('g-none');
        var rus = eng.siblings('.fgrus').removeClass('g-none');
        rus.closest('.fgroup').find('pre').html(eng.data('text'));
    });
    this.el.find('.farerules-link').click(function(event) {
        event.preventDefault();
        frPopup.css('top', 0).show();
        var fh = frPopup.outerHeight(), ft = frPopup.offset().top;
        var ws = $(window).scrollTop(), wh = $(window).height();
        frPopup.css('top', Math.min(ws + (wh - fh) / 2, ws + wh - fh - 50) - ft);
        setTimeout(function() {
            $('body').bind('click keydown', frHide);
        }, 20);
    });

    // Прекращение бронирования
    var title = $('#offers-title');
    this.stopPanel = this.el.find('.stop-booking-panel').css('top', title.height()).insertAfter(title).removeClass('g-none');
    this.stopPanel.find('.stop-booking').click(this.selfhide);
    this.el.delegate('.stop-booking', 'click', this.selfhide);
    
    // 3DSecure
    this.el.delegate('.tds-submit .link', 'click', function() {
        $(this).closest('.result').find('form').submit();
    });

    // Заголовок страницы
    pageurl.title('бронирование авиабилета ' + offersList.title.attr('data-title'));

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
    this.offersTab = offersList.selectedTab;
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
    $('.stop-booking', this.offer).remove();
    this.unfasten();
    this.offer.removeClass('active-booking');
    if (this.stopPanel) {
        this.stopPanel.remove();
    }
    this.el.remove();
    delete(this.el);
    delete(this.offer);
    delete(this.variant);
    pageurl.update('booking', undefined);
    pageurl.title('авиабилеты ' + offersList.title.attr('data-title'));    
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
    this.el.html('<div class="booking-state"><div class="progress"></div><h4>Делаем предварительное бронирование и уточняем цену</h4></div>');
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
    if (browser.search(/ipad|iphone|msie6|msie7/) !== -1) return;
    var wrapper = $('#page-wrapper');
    var ot = offer.offset().top;
    var ob = wrapper.height() - ot - offer.height();
    var cst = $(window).scrollTop();
    wrapper.addClass('l-crop');
    wrapper.children('.l-canvas').css('margin-top', 200 - ot - ob).css('top', ob - 100);
    this.dst = ot - 100;
    fixedBlocks.disabled = true;
    $(window).scrollTop(cst - this.dst);
    $('#header').addClass('g-none');
    $('#offers-title').addClass('fixed');
},
unfasten: function() {
    var wrapper = $('#page-wrapper');
    if (browser.search(/ipad|iphone|msie6|msie7/) === -1 && wrapper.hasClass('l-crop')) {
        wrapper.children('.l-canvas').css('margin-top', 0).css('top', 0);
        wrapper.removeClass('l-crop');
        $(window).scrollTop($(window).scrollTop() + this.dst);
        $('#header').removeClass('g-none');
        fixedBlocks.disabled = false;
        fixedBlocks.update();
    }
    this.dstop = 0;
}
};
