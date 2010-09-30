(function($) {

$.fn.extend({
    validate: function() {
        return this.map(app.Validate).get();
    },

    input: function(form) {
        return this.each(function() {
            new app.Input(this, form);
        });
    }
});

// валидация

app.Validate = function() {
    switch ($(this).attr('type')) {
        case 'text':
            return app.Validate.Text(this);
            break;
        case 'radio':
            return app.Validate.Radio(this);
            break;
        default: 
            return null;
    }
}

app.Validate.Radio = function(el) {
    var $el = $(el);
    var els = el.form.elements[el.name];
    for (e in els) if (els[e].checked) {l(41);return null};
l(42);
    return 'Не выбран пол пассажира';
}

app.Validate.Text = function(el) {
    var $el = $(el);
    var val = $.trim(el.value);

    // вытаскиваем правила валидации и кладём их в data('rules')
    var rules = rules || $el.data('rules') || {};

    var msg = {
        req: 'Поле {name} обязательно для заполнения',

        latin: 'В поле {name} разрешены только латинские буквы',
        num: 'В поле {name} могут быть только цифры',
        email: 'E-mail адрес не может быть таким, как в поле {name}',

        minl: 'Поле {name} не может быть таким коротким',
        maxl: 'Поле {name} не может быть таким длинным',

        min: 'В поле {name} не может быть число меньше "{val}"',
        max: 'В поле {name} не может быть число больше "{val}"',

        symbols: 'Поле {name} содержит недопустимые символы'
    };

    var isDefault = val == '' || val == rules.def;
    var qname = '"' + (el.title) + '"';

    // если поле неактивно, то все проверки неактуальны
    if ($el.attr('disabled')) return null;

    // проверка на обязательность поля
    if (rules.req && isDefault) 
        return msg.req.supplant({name: qname});

    // проверки типа
    // возможны 'latin', 'num' или 'email'
    if (rules.latin) {
        var re = /^[a-z\s]+$/i;
        if (!re.test(val)) return msg.latin.supplant({name: qname});
    }

    if (rules.num) {
        var re = /^\d+$/;
        if (!re.test(val)) return msg.num.supplant({name: qname});
    }
    if (rules.email) {
        //var re = /^[0-9a-z\._-]+@.{2,}\.[a-z]{2,6}$/i;
        
        // contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/
        var re = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i;
        if (!re.test(val)) return msg.email.supplant({name: qname});
    }

    // проверка на мин/макс длину value
    if (val.length < parseInt(rules.minl)) return msg.minl.supplant({name: qname});
    if (val.length > parseInt(rules.maxl)) return msg.maxl.supplant({name: qname});

    // числовая проверка на мин/макс
    if (rules.num && parseInt(val) < parseInt(rules.min)) return msg.min.supplant({name: qname, val: rules.min});
    if (rules.num && parseInt(val) > parseInt(rules.max)) return msg.max.supplant({name: qname, val: rules.max});

    return null;
};

// текстовое поле

app.Input = function(el, form) {
    var $el = $(el);

    // вытаскиваем правила валидации и кладём их в data('rules')
    var rules = $el.data('rules') || (function() {
        var rules = $.extend({}, {
            def: '', // фоновая подсказка в текстовом поле
            req: false, // обязательное поле

            latin: null, // тип поля, шаблон
            num: null,
            email: null,

            minl: 0, // длина значения в строковом представлении
            maxl: Number.POSITIVE_INFINITY,

            min: Number.NEGATIVE_INFINITY, // эти параметры только для 'num': true
            max: Number.POSITIVE_INFINITY,

            mask: null // разрешённые символы (regexp)
        }, (el.onclick && el.onclick()) || {});

        $el.data('rules', rules);
        return rules;
    })();


    // Инициализация

    (function() {
        // если поле не пусто и недефолтно, то убираем серый цвет
        $el.toggleClass('text-value', !isDefault());
    })();


    // Обработчики для внешних вызовов

    $el.bind('mark', function(e, mark) {
        $el.toggleClass('text-invalid', mark);
    });


    // Обработчики событий
    
    // при получении фокуса сбрасываем визуальный признак невалидности
    $el.focus(function() {
        // если есть фоновая подсказка, то прячем её
        if (rules.def && isDefault()) el.value = '';
        $el.trigger('mark', false);
    })
    .blur(function(){
        // если есть фоновая подсказка, то восстанавливаем её
        if (rules.def && isDefault()) el.value = rules.def;
        $el.toggleClass('text-value', !isDefault());
    });

    // проверяем валидность автоматически при след событиях:
    // - при потере фокуса
    $el.blur(function() {
        form.change();

        var v = $el.validate()[0];
        $el.trigger('mark', Boolean(v));
    });

    // фильтруем нажатия клавиш
    $el.keypress(function(e) {
        var passed = (e.which < 32) || !rules.mask || rules.mask.test(String.fromCharCode(e.which));

        var n = 7; // количество морганий; нечётное
        !passed && (function() {
            if (!--n) return;
            $el.toggleClass('text-invalid');
            setTimeout(arguments.callee, 50);
        })();

        return passed;
    });

    // пусто или в нём значение по умолчанию?
    function isDefault() {
        var v = $.trim(el.value);
        return v == '' || v == rules.def;
    };

};

})(jQuery);



