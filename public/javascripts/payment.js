app.booking = {
init: function() {

    var self = this;
    this.el = $('.booking');

    // Проверка формы
    this.sections = [];
    var card = this.el.find('.booking-card');
    var cardSection = this.initCard(card);
    this.validate(true);

    // Отправка формы
    $('form', this.el).submit(function(event) {
        event.preventDefault();
        if (!self.button.hasClass('a-button-ready')) return;
        var data = $(this).serialize();
        var processError = function(text) {
            self.el.append('<div class="result"><p class="fail"><strong>Упс…</strong> ' + (text || 'Что-то пошло не так.') + '</p><p class="tip">Попробуйте снова или узнайте, <a target="_blank" href="/about/#payment">какими ещё способами</a> можно купить у нас билет.</p></div>');
            self.button.addClass('a-button-ready');
        };
        self.el.find('.result').remove();
        self.button.removeClass('a-button-ready');
        self.submit.addClass('sending');
        $.ajax({
            url: $(this).attr('action'),
            data: data,
            type: 'POST',
            success: function(s) {
                if (typeof s === 'string' && s.length) {
                    var result = $(s).appendTo(self.el);
                    if (result.attr('data-type') === 'success') {
                        self.submit.addClass('latent');
                    }
                } else if (s && s.errors) {
                    var items = [];
                    for (var eid in s.errors) {
                        var ftitle = eid;
                        if (ftitle.search(/card\[number\]/i) !== -1) {
                            items.push('<li>Введён неправильный <span class="link" data-field="bc-num1">номер банковской карты</span></li>');
                        } else if (ftitle.search(/card\[type\]/i) === -1) {
                            items.push('<li>' + ftitle + ' ' + s.errors[eid] + '</li>');
                        }
                    }
                    self.button.addClass('a-button-ready');
                    self.el.find('.be-list').html(items.join(''));
                    self.el.find('.booking-errors').show();
                } else {
                    processError(s && s.exception && s.exception.message);
                }
                self.submit.removeClass('sending');
            },
            error: function() {
                processError();
                self.submit.removeClass('sending');
            },
            timeout: 90000
        });
    });
    this.submit = this.el.find('.booking-submit');
    this.button = this.submit.find('.a-button');

    // Список неправильно заполненных полей
    this.el.find('.be-list').delegate('.link', 'click', function() {
        var control = $('#' + $(this).attr('data-field'));
        var st = control.closest(':visible').offset().top - results.header.height() - 35;
        $.animateScrollTop(Math.min(st, $(window).scrollTop()), function() {
            control.focus();
        });
    });

    // Всплывающие подсказки
    this.el.delegate('.hint', 'click', function(event) {
        event.preventDefault();
        hint.show(event, $(this).parent().find('.htext').html());
    });

    // 3DSecure
    this.el.delegate('.tds-submit .a-button', 'click', function(event) {
        event.preventDefault();
        $(this).closest('.result').find('form').submit();
    });

}};