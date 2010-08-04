/*
    ВНЕШНИЙ ВИД

    - яркое двойное подчёркивание в верхней строке
    - две колонки
    - скругление в эксплорере? (см. css и 
        http://bolknote.ru/2008/07/18/~1786#55
        http://blog.ad.by/2008/03/nice-rounded-corners-for-ie-safari.html
        http://www.dillerdesign.com/experiment/DD_roundies/
        http://web-standards.ru/articles/cross-browser-rounded-corners/
     )

    ПОВЕДЕНИЕ

    КОД

    - прятать все открытые попапы по событию, 
      а также при клике мимо списка (отдельно хэндлить клик в попап)
      а также по Esc
    - кидать событие 'change'

    КОСЯКИ


*/

;(function($) {
    
$.fn.extend({
    define: function() {
        return this.each(function() {
            new app.Define($(this));
        });
    }
});

/* =======  Фильтрующая ссылка  ======== */

app.Define = function($el) {
    var me = this;
    
    this.$el = $el;

    // кликабельный заголовок
    this.$label = $('a', $el).first();

    // кликабельное значение/ия
    this.$value = $('b', $el).first();

    // возможные значения фильтра
    this.values = null;
    
    // выбранные значения
    this.value = [];
    this.value.keys = {};

    // всплывающий список; создаём только при первом клике
    this.$popup = null;

    // параметры фильтра, заданные в html
    this.options = $el.attr('onclick')();

    this.options.anyone = this.options.anyone || 'неважно';
    this.anyone = {v: null, t: this.options.anyone};
    
    this.$label.click(function(e) {
        e.preventDefault();
        if (!me.values) return false;

        me.$popup = me.$popup || new app.Define.Popup(me);

        var pos = $('u', this).offset();
        me.$popup.show(me.values, pos);
    });

    this.$value.delegate('a', 'click', function(e) {
        e.preventDefault();

        var $val = $(this);

        $val.fadeTo(300, 0.6, function() {
            me.remove($val.data('data'));
        });
    });

    $el.bind('update', function(e, filters) {
        me.values = filters[me.options.name];
        me.reset();
    });

    $el.bind('add', function(e, item) {
        me.add(item);
    });

	$el.data('name', this.options.name);

    return this;
};

app.Define.prototype = {

    set: function(data) {
        data = data || [];
        data = $.isArray(data) ? data : [data];

        this.update(data);
    },

    reset: function() {
        this.set();
    },

    add: function(item) {
        this.value.push(item)

        // если (руками!) отмечены все доступные значения, то сбрасываем в дефолтное состояние
        if (this.value.length == this.values.length) this.value = [];

        this.update(this.value);
    },

    remove: function(item) {
        var data = $.grep(this.value, function(Item) {
            return Item.v != item.v;
        });
        this.update(data);
    },

    get: function() {
        return this.value;
    },

    has: function(item) {
        if (item) 
            // есть среди ключей такое значение?
            return this.value.keys.hasOwnProperty(item.v);
        else
            // если аргумент не передан, то проверяем состояние на "дефолтность"
            return this.value.length == 0
    },

    update: function(value) {
        var me = this;

        me.value = [];
        me.value.keys = {};

        me.$value.empty();

        value.length && $.each(value, function(index, item) {

            me.value.push(item);
            me.value.keys[item.v] = item.t;

            // отрисовываем значение
            me.$value.append(
                    $('<a/>')
                    .attr('href', '#')
                    .attr('title', 'Убрать «' + item.t + '»')
                    .data('data', item)
                    .append(
                        $('<u/>').html(item.t)
                    )
            );

            // разделитель между значениями
            var sep = index + 2 == value.length ? ' и' : ',';
            index + 1 < value.length && me.$value.append($('<u/>').text(sep));
        });

        var title;
        if (me.options.radio) {
            title = 'Выбрать ' + me.options.accusative;
            title+= '. '
            title+= 'По умолчанию считается, что ' + me.options.anyone;
            title+= '.'
        }
        else {
            title = (me.has() ? 'Уточнить ' : 'Добавить или убрать ') + me.options.accusative;
            title += '. ';

            var total = (me.values.length > 2) ? 'Сейчас выбраны все ' + app.constant.numbers.nomimative[me.values.length] + ' возможных.' : '';
            var anyone = 'Если годятся все, нажмите «' + me.options.anyone + '»';
            title += me.has() ? total : anyone;
        }

        me.$label[0].title = title;
        me.$el.data('value', me.value).trigger('change');
    }

}

/* =======  Всплывающий список  ======== */

app.Define.Popup = function(define) {
    var me = this;
    var _const = {offsetTop: 6, offsetLeft: 18};
    var timeout;

    if (define.options.popup) {
        var $el = $(define.options.popup);
        var $dl = $('dl', $el).click(onClickStatic);

        // исходное значение - один взрослый
        $el.data('value', [1, 0, 0]);

        $el.data('btn', $('> a.a-button', $el));
        $el.data('btn').click(function(e) {
            hide(300);
            return false;
        });

        $dl.slice(1,3).hover(
            function(e) {
                var $this = $(this);
                $el.data('value')[$dl.index($this)] || $this.fadeTo(200, 1); // $this.removeClass('fade')
            },
            function(e) {
                var $this = $(this);
                $el.data('value')[$dl.index($this)] || $this.fadeTo(200, 0.2); // $this.addClass('fade')
            }        
        );
    }
    else {
        // создаём окошко-контейнер
        var $el = $('<div/>').appendTo(document.body);
        // ..и список
        var $dl = $('<dl/>').appendTo($el).click(onClick);
    }

    // оформление окошка
    $el.addClass('define-popup');
    if (define.options.radio) $el.addClass('define-popup-radio');

    // подгоняем размер шрифта под "родительский"
    $el.css('fontSize', define.$el.css('fontSize'));


    // события на контейнере
    $el.mouseleave(function() {
return;
        clearTimeout(timeout);
        timeout = setTimeout(function(){
            hide(300);
        }, 500);
    })
    .mouseenter(function() {
        clearTimeout(timeout);
    })
    .bind('mousewheel DOMMouseScroll', function(e) {
        e.preventDefault();

        var d = (e.wheelDelta || -e.detail) > 0 ? 1 : -1;

        $el.stop(true, true);

        var top = $el.position().top + d * wheelStep();

        var max = $el.data('offset').top;
        var min = max - $el.data('height');

        if (top < max && top > min) $el.animate({top: top}, 200);
    });

    // клик по элементу динамического списка
    function onClick(e) {
        clearTimeout(timeout);
        e.preventDefault();
        e = e.target;

        if (e.tagName == 'DT') return hide(300);
        if (e.tagName != 'A') return;
        var $a  = $(e);

        var radioMode = define.options.radio;
        var isAnyone  = $a.hasClass('anyone');
        var isChecked = $a.hasClass('checked');

        // уже отмеченные дефолтный элемент либо радио-элемент: выходим
        if (isChecked && (isAnyone || radioMode)) return hide(300);
            
        // выбор действия
        var action = isAnyone ? 'reset' : (radioMode ? 'set' : (isChecked ? 'remove' : 'add'));

        $a.toggleClass('checked');
        define[action]($a.data('data'));
        
        hide(500);
    };

    // клик по элементу статического списка (пассажиры)
    function onClickStatic(e) {
        clearTimeout(timeout);
        e.preventDefault();
        e = e.target;

        if (e.tagName == 'DT') return hide(300);
        if (e.tagName != 'A') return;
        var $a  = $(e);

        // кликнутое значение
        var v = parseInt($a[0].onclick());
        // массив текущих значений
        var value  = $el.data('value');

        // клик по взрослым, но дети при этом не выбраны - можно закрыть окно
        if (v <= 100 && !(value[1] + value[2])) hide(500);

        // это клик по уже отмеченному элементу - ничего не делаем
        if ($a.hasClass('checked')) return;
        // снимаем выделение со всех ранее выделенных пунктов
        $('dd a', $(this)).removeClass('checked');
        // и выделяем тот, по которому кликнули
        $a.addClass('checked');


        // запоминаем новое значение
        if (v < 100) value[0] = v % 10;
        if (v >= 100 && v < 1000) value[1] = v % 100;
        if (v >= 1000) value[2] = v % 1000;
        $el.data('value', value);

        // прячем или показываем кнопку закрывания окна
        $el.data('btn').toggleClass('g-none', !(value[1] + value[2]));

        // выбор действия
            // дефолтное значение - один взрослый без детей
            // var action = (value[0] == 1 && !value[1] && !value[2]) ? 'reset' : 'set';
        var action = (!value[0] && !value[1] && !value[2]) ? 'reset' : 'set';

        // формируем значения и их текст для отображения в заголовке фильтра
        var i = -1, data = [];
        while (++i < $dl.length) value[i] && data.push({
                v: value[i] + Math.pow(10, i + 1),
                // строчка для взрослых формируется хитрожопо:
                // если детей нет, то пишем "двое", иначе добавляем - "двое взрослых"
                t: app.constant.numbers.collective[value[i]] + ((i > 0 || (value[1] + value[2])) ? (' ' + app.utils.plural(value[i], $dl[i].onclick())) : '')
            }
        );

        define[action](data);
    };

    // создаёт DOM-элемент отдельного значения
    function makeItem(item, checked, anyone) {
        var $a = $('<a/>').attr('href', '#').data('data', item).html(item.t);

        // отмеченное значение
        checked && $a.addClass('checked');

        // дефолтное значение
        anyone && $a.addClass('anyone');

        return $('<dd/>').append($a.append('<i/>'));
    };

    // населяет список значениями, расставляет галочки
    function fillList(values) {
        $dl.empty();

        $dl.append($('<dt/>').text(define.options.title));

        $dl.append(makeItem(define.anyone, define.has(), true));

        $.each(values, function(index, item) { 
            $dl.append(makeItem(item, define.has(item), false));
        });
    };

    // снимает ненужные галочки в списке пассажиров
    function fillListStatic() {
        var i = -1, data = [];
        //while (++i < $dl.length) l( $('dd', $dl[i]) );

        $('dl a', $el).each(function(index, el) {
            var hasValue = define.has({v: parseInt(el.onclick())});
            $(el).toggleClass('checked', hasValue);

// todo: надо выставлять галочки также на элементы "нет"

        });
    };

    // обновляет динамический список; позиционирует окно
    function show(values, offset) {
        define.options.popup ? fillListStatic() : fillList(values);

        $el.css({left: offset.left - _const.offsetLeft, top: offset.top - _const.offsetTop});
        $el.fadeIn(200, function(){
            $el.data('offset', offset);
            $el.data('height', $el.height());
        });
    };

    function hide(t) {
        t ? $el.fadeOut(t) : $el.hide();
    };

    // высота первого элемента списка
    function wheelStep(item, checked, anyone) {
        var h = $($('dd', $el)[1]);
        if (!h) return;

        h = h.outerHeight(true)
        h = (h > 0 && h < 100) ? h : 25;

        wheelStep = function(){return h};
        return h;
    };

    return {
        show: show,
        hide: hide
    }
};

})(jQuery);
