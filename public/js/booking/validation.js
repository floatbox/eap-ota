(function($) {

$.fn.extend({
    validate: function() {
        return this.map(app.Validate).get();
    },

    inputtext: function(form) {
        return this.each(function() {
            new app.InputText(this, form);
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

// валидация радиобаттона - хоть один из одноимённых рб должен быть отмечен

app.Validate.Radio = function(el) {
    var $el = $(el);
    var els = el.form.elements[el.name];
    for (var i = els.length; i--;) if (els[i].checked) return null;

    var qname = '<a href="#" data-id="' + $el.attr('id') + '"><u>' + (el.title) + '</u></a>';
    return 'не выбран {name}'.supplant({name: qname});
}

// валидация текстового поля в согласии с наложенными правилами

app.Validate.Text = function(el) {
    var $el = $(el);
    var val = $.trim(el.value);

    // вытаскиваем правила валидации и кладём их в data('params').rules
    var params = $el.data('params') || (function() {
        var params = $.extend({}, {
            def: '', // фоновая подсказка в текстовом поле
            mask: null,
            rules: {
                req: false, // обязательное поле

                latin: null, // тип поля, шаблон
                num: null,
                email: null,

                minl: 0, // длина значения в строковом представлении
                maxl: Number.POSITIVE_INFINITY,

                min: Number.NEGATIVE_INFINITY, // эти параметры только для 'num': true
                max: Number.POSITIVE_INFINITY
            }
        }, (el.onclick && el.onclick()) || {});

        $el.data('params', params);
        return params;
    })();

    var rules = params.rules;

    var msg = {
        reqM: 'не указан {name}',
        reqF: 'не указана {name}',
        reqN: 'не указано {name}',
        req: 'поле «{name}» обязательно для заполнения',

        latin: 'в поле «{name}» разрешены только латинские буквы',
        latinF: '{name} должна быть написана латинскими буквами',
        latinN: '{name} должно быть написано латинскими буквами',        
        num: 'в поле «{name}» могут быть только цифры',
        numM: '{name} должен быть числом',
        numF: '{name} должна быть числом',        
        email: 'E-mail адрес не может быть таким, как в поле {name}',

        minl: '{name} не может быть таким коротким',
        maxl: '{name} не может быть таким длинным',
        minlF: '{name} не может быть такой короткой',
        maxlF: '{name} не может быть такой длинной',

        min: '{name} не может быть меньше {val}',
        max: '{name} не может быть больше {val}'
    };

    var isDefault = val == '' || val == params.def;
    var qname = '<a href="#" data-id="' + $el.attr('id') + '"><u>' + (el.title) + '</u></a>';

    var processMessage = function(key, gender, data) {
        var keyg = gender ? (key + gender) : key;
        return (msg[keyg] || msg[key]).supplant(data);
    };

    // если поле неактивно, то все проверки неактуальны
    if ($el.attr('disabled')) return null;

    // проверка на обязательность поля
    if (rules.req && isDefault) 
        return processMessage('req', rules.gender, {name: qname});

    // проверки типа (возможны 'latin', 'num' или 'email')
    if (rules.latin) {
        var re = /^[a-z\s]+$/i;
        if (!re.test(val)) return processMessage('latin', rules.gender, {name: qname});
    }
    if (rules.num) {
        var re = /^\d+$/;
        if (!re.test(val)) return processMessage('num', rules.gender, {name: qname});
    }
    if (rules.email) {
        // contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/
        var re = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i;
        if (!re.test(val)) return msg.email.supplant({name: qname});
    }
    
    // проверка на мин/макс длину value
    if (val.length < parseInt(rules.minl)) return processMessage('minl', rules.gender, {name: qname});
    if (val.length > parseInt(rules.maxl)) return processMessage('maxl', rules.gender, {name: qname});

    // числовая проверка на мин/макс
    if (rules.num && parseInt(val, 10) < parseInt(rules.min)) return processMessage('min', rules.gender, {name: qname, val: rules.min});
    if (rules.num && parseInt(val, 10) > parseInt(rules.max)) return processMessage('max', rules.gender, {name: qname, val: rules.max});

    return null;
};

// текстовое поле - общее поведение

app.InputText = function(el, form) {
    var $el = $(el);
    
    // могут быть: mask - разрешённые символы (regexp)
    // могут быть: def  - дефолтный текст (строка)
    var params = el.onclick && el.onclick() || {};

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
        if (params.def && isDefault()) el.value = '';
        $el.trigger('mark', false);
    }).blur(function(){
        // если есть фоновая подсказка, то восстанавливаем её
        if (params.def && isDefault()) el.value = params.def;
        $el.toggleClass('text-value', !isDefault());
        // определять изменения больше не нужно
        clearTimeout(compareTimer);
    });

    // Проверяем валидность при потере фокуса
    $el.bind('blur', function() {
        form.change();
        var v = $el.validate()[0];
        $el.trigger('mark', Boolean(v));
    });

    // Проверяем валидность при изменении, если осталась одна ошибка
    $el.bind('changeval', function() {
        if (!form.state || form.state.length < 2) form.change();
    });
    
    // Определяем изменение без потери фокуса
    var storedValue;
    var compareTimer;
    var compare = function() {
        var value = $el.val();
        if (value != storedValue) {
            storedValue = value;
            $el.trigger('changeval');
        }
    };
    $el.keyup(function() {
        clearTimeout(compareTimer);
        setTimeout(compare, 750);
    });

    // фильтруем нажатия клавиш
    $el.keypress(function(e) {
        var passed = (e.which < 32) || !params.mask || params.mask.test(String.fromCharCode(e.which));

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
        return v == '' || v == params.def;
    };

};

})(jQuery);
