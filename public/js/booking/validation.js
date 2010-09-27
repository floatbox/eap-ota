(function($) {

$.fn.extend({
    validate: function() {
        return this.map(app.Validate);
    },

    input: function(form) {
        return this.each(function() {
            new app.Input(this, form);
        });
    }
});

// валидация

app.Validate = function() {
    var el  = this;
    var $el = $(el);
    var val = $.trim(el.value);

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

    var isDefault = val == '' || val == rules.def;
    var qname = '"' + (el.title) + '"';


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
    var rules = el.onclick && el.onclick() || {};
    var def  = rules.def;
    var mask = rules.mask;

    // Инициализация

    (function(){
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
        if (def && isDefault()) el.value = '';
        $el.trigger('mark', false);
    })
    .blur(function(){
        // если есть фоновая подсказка, то восстанавливаем её
        if (def && isDefault()) el.value = def;
        $el.toggleClass('text-value', !isDefault());
    });

    // проверяем валидность автоматически при след событиях:
    // - при потере фокуса
    $el.blur(function() {
        var v = $el.validate()[0];
        $el.trigger('mark', Boolean(v));
    });

    $el.keypress(function(e) {
        //var key = e.charCode || e.keyCode;
        //if (e.ctrlKey || e.altKey || key < 32 || (key > 34 && key < 41) || key == 46) return true;
        //abcdefghijklmnopqrstuvwxyz
        // t.re = (i < 6) ? /\d/ : /[a-fA-F0-9]/;

        return (e.which < 32) || !mask || mask.test(String.fromCharCode(e.which));
    });

    // пусто или в нём значение по умолчанию?
    function isDefault() {
        var v = $.trim(el.value);
        return v == '' || v == def;
    };

/*
    t.onkeypress = test;
    t.onkeyup = t.oncut = t.onpaste = validate;
    t.onfocus = focus;
    t.onblur = blur;

    function test(e) {
        e = e || event;
        this.className = '';

        var key = e.charCode || e.keyCode;
        if (e.ctrlKey || e.altKey || key < 32 || (key > 34 && key < 41) || key == 46) return true;
        if (key == 32) return false;

        var char = String.fromCharCode(key);

        // t.re = (i < 6) ? /\d/ : /[a-fA-F0-9]/;
        return this.re.test(char);
    }

    function validate(e) {
        e = e || event;
        var key = e.charCode || e.keyCode;
        var f = this;

        if (_this.timerId) {
            window.clearTimeout(_this.timerId);
            _this.timerId = null;
        }

        _this.timerId = window.setTimeout(function() {
            _this.validate(f, key);
        }, 300);

        _this.counter && _this.counter() || (_this.counter = null);
    }

    function focus() {
        this.hasFocus = 1;
    }

    function blur(e) {
        this.hasFocus = 0;
        this.className = '';

        var n = parseInt(this.value, this.radix);

        window.setTimeout(function() {
            _this.set(true);
        }, 10);
    }

*/




};

})(jQuery);



