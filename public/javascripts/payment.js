(function() {

    // Проверка полей
    var context = $('.booking');
    var sections = context.find('.section[onclick]');
    var steps = $.map(sections, function(el, i) {
        return new (app[el.onclick()])(el, i);
    });
    for (var i = steps.length; i--;) {
        steps[i].change();
    }

    // Отправка формы
    $('form', context).submit(function(event) {
        event.preventDefault();
        if (button.hasClass('a-button-ready')) {
            var data = $(this).serialize();
            var rcontrol = button.removeClass('a-button-ready').closest('.control');
            context.find('.result').remove();
            context.find('.book-s').removeClass('book-retry');
            $.ajax({
                url: $(this).attr('action'),
                data: data,
                type: 'POST',
                success: function(s) {
                    if (typeof s === 'string' && s.length) {
                        var result = $(s).appendTo(context);
                        var rtype = result.attr('data-type');
                        if (result.attr('data-type') === 'fail') {
                            context.find('.book-s').addClass('book-retry');
                            button.addClass('a-button-ready');
                        } else {
                            context.find('.book-s').addClass('g-none');
                        }
                    } else if (s && s.errors) {
                        var items = [];
                        for (var eid in s.errors) {
                            var ftitle = eid;
                            if (ftitle.search(/card\[number\]/i) !== -1) {
                                items.push('<li>введён неправильный <a href="#" data-id="bc-num1"><u>номер карты</u></a></li>');
                            } else if (ftitle.search(/card\[type\]/i) === -1) {
                                items.push('<li>' + ftitle + ' ' + s.errors[eid] + '</li>');
                            }
                        }
                        button.addClass('a-button-ready');
                        context.find('.blocker').show().find('.b-pseudo').html(items.join(''));
                        context.removeClass('book-retry');
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
        }
    });
    var button = context.find('.a-button');
    var processError = function(text) {
        context.find('.book-s').addClass('book-retry');
        context.append('<div class="result"><p class="fail"><strong>Упс…</strong> ' + (text || 'Что-то пошло не так.') + '</p><p class="tip">Попробуйте снова или свяжитесь с&nbsp;нами по&nbsp;электронной почте <a href="mailto:support@eviterra.com">support@eviterra.com</a>.</p></div>');
        button.addClass('a-button-ready');
    };

    // Список неправильно заполненных полей
    $('.blocker', this.el).delegate('a', 'click', function(event) {
        event.preventDefault();
        $('#' + $(this).attr('data-id')).focus();
    });
    sections.bind('setready', function() {
        var ready = true, errors = [];
        for (var i = 0, im = steps.length; i < im; i++) {
            var step = steps[i];
            if (!step.ready) {
                ready = false;
                if (step.state) {
                    errors = errors.concat(step.state);
                }
            }
        }
        button.toggleClass('a-button-ready', ready);
        var blocker = $('.blocker', context).toggle(!ready);
        if (!ready && errors.length) {
            $('.b-pseudo', blocker).html('<li>' + errors.slice(0, 3).join('</li><li>') + '</li>');
        }
    });
    sections.eq(0).trigger('setready');

    // 3DSecure
    context.delegate('.tds-submit .a-button', 'click', function(event) {
        event.preventDefault();
        $(this).closest('.result').find('form').submit();
    });

})();