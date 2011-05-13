booking.form.init = function() {
    var that = this;
    this.el = $('.booking-form');

    // Всплывающие подсказки
    this.el.delegate('.hint', 'click', function(event) {
        event.preventDefault();
        hint.show(event, $(this).parent().find('.htext').html());
    });

    // Список неправильно заполненных полей
    this.el.find('.be-list').delegate('.link', 'click', function() {
        var control = $('#' + $(this).attr('data-field'));
        var st = control.closest(':visible').offset().top - $('#header').height() - 35;
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

    // Проверка формы
    this.sections = [];
    var card = this.el.find('.booking-card');
    var cardSection = this.initCard(card);
    this.validate(true);

};
booking.form.process = function(result) {
    switch (this.el.find('.result').attr('data-type')) {
    case 'success':
        this.submit.addClass('latent');
        break;
    case '3dsecure':
        this.submit.addClass('latent');
        break;
    case 'fail':
        this.button.addClass('a-button-ready');
        break;
    }
};
booking.form.error = function(text) {
    var block = $('<div class="result"></div>');
    block.append('<p class="fail"><strong>Упс…</strong> ' + (text || 'Что-то пошло не так.') + '</p>');
    block.append('<p class="tip">Свяжитесь с нами по электронной почте <a href="mailto:support@eviterra.com">support@eviterra.com</a> или позвоните <nobr>(+7 495 660-35-20) &mdash;</nobr> мы&nbsp;разберемся.</p>');
    this.el.append(block);
};
