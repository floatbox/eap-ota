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
        $.post($(this).attr('action'), data, function(s) {
            self.el.find('.result').remove();
            if (typeof s == 'string') {
                var result = $(s).appendTo(self.el);
                var rtype = result.attr('data-type');
                self.el.find('.book-s').addClass(rtype == 'success' ? 'g-none' : 'book-retry');
                pageurl.update('payment', rtype);
            } else if (s.errors) {
                var items = [];
                for (var eid in s.errors) items.push('<li>' + eid + ' ' + s.errors[eid] + '</li>');
                self.el.find('.blocker').show().find('.b-pseudo').html(items.join(''));
                self.el.removeClass('book-retry');
            } else if (s.exception) {
                alert(s.exception.message);
            }
            self.submit.addClass('a-button-ready').closest('.control').removeClass('sending');
        });
        self.submit.removeClass('a-button-ready').closest('.control').addClass('sending');
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
        hint.show(event, $(this).next('p').html());
    });

    // Текст тарифа
    $('#tarif-expand').click(function(e) {
        e.preventDefault();
        $('#tarif-text').slideToggle(200);
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
    this.el.find('.farerules-link').click(function(event) {
        event.preventDefault();
        frPopup.show().css('margin-top', 15 - Math.round(frPopup.outerHeight() / 2));
        setTimeout(function() {
            $('body').bind('click keydown', frHide);
        }, 20);
    });

    // Прекращение бронирования
    this.el.delegate('a.stop-booking', 'click', this.selfhide);
    
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
    /*var link = $('<a class="stop-booking" href="#">Вернуться к выбору вариантов</a>').click(this.selfhide).prependTo(this.offer);
    if (this.offer.parent('#offers-matrix').length) {
        link.css('top', this.offer.find('.offer-prices').height());
    }*/
    this.offer.addClass('active-booking');
},
hide: function() {
    $('.stop-booking', this.offer).remove();
    this.unfasten();
    this.offer.removeClass('active-booking');
    this.el.remove();
    delete(this.el);
    delete(this.offer);
    delete(this.variant);
    pageurl.update('booking', undefined);
    pageurl.title('авиабилеты ' + offersList.title.attr('data-title'));    
},
book: function(variant) {
    var self = this;
    this.el.html('<div class="booking-state"><div class="progress"></div><h4>Делаем предварительное бронирование и уточняем цену</h4></div>');
    var vid = '&variant_id=' + [self.offersTab, this.variant.attr('data-index')].join('-');
    $.get("/booking/preliminary_booking?" + variant.attr('data-booking') + vid, function(s) {
        $('#offers-tabs').trigger('set', self.offersTab);
        if (s && s.success) {
            self.load(s.number);
            pageurl.update('booking', s.number);
        } else {
            var message = $('<div class="booking-state"><h4>В данный момент невозможно выбрать этот вариант</h4><p><span class="link">Почему?</span></p></div>');
            message.find('.link').click(function(event) {
                hint.show(event, 'Так иногда бывает, потому что авиакомпания не&nbsp;может подтвердить наличие мест на&nbsp;этот рейс по&nbsp;этому тарифу. К&nbsp;сожалению, от&nbsp;нас это не&nbsp;зависит. Спасибо за&nbsp;понимание.');
            });
            self.el.html('').append(message);
        }
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
        var block = $('<div class="diff-price"></div>');
        var template = '<h5>Цена этого варианта изменилась: стало <strong>{type} на {value}&nbsp;{currency}</strong> (<span class="link">почему?</span>)</h5>';
        block.append(template.supplant({
            type: bp > vp ? 'дороже' : 'дешевле',
            currency: app.utils.plural(Math.abs(bp - vp), ['рубль', 'рубля',  'рублей']),
            value: Math.abs(bp - vp)
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
    $(window).scrollTop(cst - this.dst);
},
unfasten: function() {
    var wrapper = $('#page-wrapper');
    if (browser.search(/ipad|iphone|msie6|msie7/) === -1 && wrapper.hasClass('l-crop')) {
        wrapper.children('.l-canvas').css('margin-top', 0).css('top', 0);
        wrapper.removeClass('l-crop');
        $(window).scrollTop($(window).scrollTop() + this.dst);
    }
    this.dstop = 0;
}
};
