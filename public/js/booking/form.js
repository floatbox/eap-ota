/* Booking form */
app.booking = {
init: function() {
    var self = this;
    var sections = $('.section[onclick]', this.el);
    this.steps = $.map(sections, function(el, i) {
        return new (app[el.onclick()])(el, i);
    });

    $('form', this.el).submit(function(event) {
        event.preventDefault();
        if (!self.submit.hasClass('a-button-ready')) return;
        var data = $(this).serialize();
        $.post($(this).attr('action'), data, function(s) {
            if (typeof s == 'string') {
                self.el.append(s);
                $('.book-s', self.el).addClass('g-none');
            } else {
                var blocker = $('.blocker', self.el);
                $('.b-pseudo', blocker).html(s);
                blocker.toggle(true);
            }
        });
    });

    // раскрывающаяся подсказка
    $('.b-expand').mousedown(function(e) {
        var $u = $(this);
        $u.toggleClass('b-expand-up');
        $u.next('p').slideToggle(200);
    });

    // текст тарифа
    $('#tarif-expand').click(function(e) {
        e.preventDefault();
        $('#tarif-text').slideToggle(200);
    });
    this.submit = $('.book-s .a-button', this.el);
    for (var i = this.steps.length; i--;) {
        this.steps[i].change();
    }

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

    // Прекращение бронирования
    $('.stop-booking', this.el).click(this.selfhide);
},
show: function(variant) {
    var self = this;
    if (this.el) this.hide();
    this.offer = variant.parent();
    if (this.offer.hasClass('collapsed')) {
        $('.expand', variant).click();
    }
    this.selfhide = function(event) {
        event.preventDefault();
        self.hide();
    };    
    var button = '<a class="stop-booking" href="#">Вернуться к выбору вариантов</a>';
    $(button).click(this.selfhide).prependTo(this.offer);
    this.el = $('<div class="booking"></div>').appendTo(this.offer);
    this.offer.addClass('active-booking');
},
hide: function() {
    $('.stop-booking', this.offer).remove();
    this.unfasten();
    this.offer.removeClass('active-booking');
    this.el.remove();
    this.hash();
    delete(this.el);
},
book: function(variant) {
    var self = this;
    this.el.html('<div class="empty"><span class="loading">Предварительное бронирование</span></div>');
    $.get("/booking/preliminary_booking?" + variant.attr('data-booking'), function(s) {
        if (s && s.success) {
            self.hash(s.number);
            self.load(s.number);
        } else {
            self.el.html('<div class="empty">Не удалось забронировать.</div>');
        }
    });
    var w = $(window), offset = this.el.offset().top;
    if (offset > w.scrollTop() + w.height()) {
        $({st: w.scrollTop()}).animate({
            st: offset - w.height() + 250 
        }, {
            duration: 800,
            step: function() {
                w.scrollTop(this.st);
            }
        });
    }
},
hash: function(h) {
    var hparts = window.location.hash.substring(1).split(':');
    if (h) hparts[1] = h; else hparts.length = 1;
    window.location.hash = hparts.join(':');
},
load: function(number) {
    var self = this;
    $.get("/booking/", {number: number}, function(s) {
        self.el = $(s).replaceAll(self.el);
        if (self.el.children('form').length) {
            self.fasten(self.offer);
            self.init();
        }
    });
},
fasten: function(offer) {
    var wrapper = $('#page-wrapper');
    var ot = offer.offset().top;
    var ob = wrapper.height() - ot - offer.height();
    var cst = $(window).scrollTop();
    wrapper.addClass('l-crop');
    wrapper.children('.l-canvas').css('margin-top', 220 - ot - ob).css('top', ob - 110);
    this.dst = ot - 110;
    $(window).scrollTop(cst - this.dst);
},
unfasten: function() {
    var wrapper = $('#page-wrapper');
    if (wrapper.hasClass('l-crop')) {
        wrapper.children('.l-canvas').css('margin-top', 0).css('top', 0);
        wrapper.removeClass('l-crop');
        $(window).scrollTop($(window).scrollTop() + this.dst);
    }
    this.dstop = 0;
}
};
