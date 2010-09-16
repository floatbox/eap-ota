(function($) {
    
$.fn.extend({
    validate: function(form) {
        return this.each(function() {
            var rules = this.onclick && this.onclick();
            new app.Validate(this, rules, form);
        });
    }
});

app.Validate = function(el, rules, form) {
    var $el = $(el);

    rules = $.extend({}, {
        def: null, // фоновая подсказка в текстовом поле
        req: false, // обязательное поле

        latin: null, // тип поля, шаблон
        num: null,
        email: null,

        minl: 0, // длина значения в строковом представлении
        maxl: Number.POSITIVE_INFINITY,

        min: Number.NEGATIVE_INFINITY, // эти параметры только для 'num': true
        max: Number.POSITIVE_INFINITY,

        symbols: null // регулярное выражение
    }, rules || {});


    // Инициализация

    (function(){
        // если поле не пусто и недефолтно, то убираем серый цвет
        $el.toggleClass('text-value', !isDefault());
    })();


    // Обработчики для внешних вызовов

    $el.bind('validate', function() {
        $el.data('valid', validate());
    });

    $el.bind('mark', function(e, mark) {
        $el.toggleClass('text-invalid', mark);
    });


    // Обработчики событий
    
    // если настроена фоновая подсказка, то при получении фокуса прячем её
    if (rules.def)
        $el.focus(function() {
            if (isDefault()) el.value = '';
        })
        // а при уходе - возвращаем
        .blur(function(){
            if (isDefault()) el.value = rules.def;
        });

    // при получении фокуса сбрасываем визуальный признак невалидности
    $el.focus(function() {
        $el.trigger('mark', false);
    });

    // проверяем валидность автоматически при след событиях:
    // - при потере фокуса
    $el.blur(function(){
        var v = whatsWrong();

        $el.toggleClass('text-value', !isDefault());

v && l(v);
        $el.trigger('mark', Boolean(v));

    });


    // Вспомогательные проверки

    // пусто или в нём значение по умолчанию?
    function isDefault() {
        return $.trim(el.value) == '' || 
               rules.def && $.trim(el.value) == rules.def;
    };


    // Главная функция - валидация на основе заданных правил

    function whatsWrong() {
        var msg = {
            req: 'Поле {name} обязательно для заполнения',

            latin: 'В поле {name} разрешены только латинские буквы',
            num: 'Поле {name} должно быть числом',
            email: 'Поле {name} не является E-mail адресом',

            minl: 'Длина поля {name} слишком короткая, чтобы быть правильной',
            maxl: 'Длина поля {name} слишком велика',

            min: 'Правильное значение поля {name} не может быть меньше "{val}"',
            max: 'Правильное значение поля {name} не может быть больше "{val}"',

            symbols: 'Поле {name} содержит недопустимые символы'
        };

        rules.qname = '"' + (el.title) + '"';

        var res = true;
        var val = $.trim(el.value);

        // проверка на обязательность поля
        if (rules.req && isDefault()) return msg.req.supplant({name: rules.qname});

        // проверки типа
        // возможны 'latin', 'num' или 'email'
        if (rules.latin) {
            var re = /^[a-z\s]+$/i;
            if (!re.test(val)) return msg.latin.supplant({name: rules.qname});
        }
        if (rules.num) {
            var re = /^\d+$/i;
            if (!re.test(val)) return msg.num.supplant({name: rules.qname});
        }
        if (rules.email) {
            //var re = /^[0-9a-z\._-]+@.{2,}\.[a-z]{2,6}$/i;
            
            // contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/
            var re = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i;
            if (!re.test(val)) return msg.email.supplant({name: rules.qname});
        }

        // проверка на мин/макс длину value
        if (val.length < parseInt(rules.minl)) return msg.minl.supplant({name: rules.qname});
        if (val.length > parseInt(rules.maxl)) return msg.maxl.supplant({name: rules.qname});

        // числовая проверка на мин/макс
        if (rules.num && parseInt(val) < parseInt(rules.min)) return msg.min.supplant({name: rules.qname, val: rules.min});
        if (rules.num && parseInt(val) > parseInt(rules.max)) return msg.max.supplant({name: rules.qname, val: rules.max});

        return false;
    };


};

})(jQuery);



