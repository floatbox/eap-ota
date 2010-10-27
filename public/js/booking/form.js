/* Booking form */
app.booking = {
init: function() {
    var sections = $('.section[onclick]', this.el);
    this.steps = $.map(sections, function(el, i) {
        return new (app[el.onclick()])(el, i);
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
},
load: function(variant) {
    var self = this;
    if (this.el) this.stop();
    this.offer = variant.parent();
    if (this.offer.hasClass('collapsed')) {
        $('.expand', variant).click();
    }
    var button = '<a class="a-button stop-booking" href="#">Вернуться к выбору вариантов</a>';
    var stop = function(event) {
        event.preventDefault();
        self.stop();
    };
    $(button).click(stop).prependTo(this.offer);
    $(button).click(stop).appendTo(this.offer);
    this.offer.addClass('active-booking');
    this.el = $('<div class="booking"><div class="empty">Предварительное бронирование…</div></div>').appendTo(this.offer);
    $.get("/booking/?" + variant.attr('data-booking'), function(s, status, request) {
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
    wrapper.children('.l-canvas').css('margin-top', 200 - ot - ob).css('top', ob - 100);
    this.dst = ot - 100;
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
},
stop: function() {
    $('.stop-booking', this.offer).remove();
    this.unfasten();
    this.offer.removeClass('active-booking');
    this.el.remove();
    delete(this.el);
}
};
