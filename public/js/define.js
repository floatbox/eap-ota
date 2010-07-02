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
        me.set();
    });

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
            index + 1 < value.length && me.$value.append($('<u/>').text(' или'));
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
    }

}

/* =======  Всплывающий список  ======== */

app.Define.Popup = function(define) {
    var _const = {offsetTop: 6, offsetLeft: 16};
    var timeout;

    // создаём DOM-элемент
    var $el = $('<dl/>')
    .addClass('define-popup')
    .css('fontSize', define.$el.css('fontSize'))
    .appendTo(document.body);

    define.options.radio && $el.addClass('define-popup-radio');

    // клик по элементу списка
    $el.click(function(e) {
        clearTimeout(timeout);
        e.preventDefault();

        if (e.target.tagName == 'A') {
            var $a  = $(e.target);

            var item = $a.data('data');

            var radioMode = define.options.radio;
            var isAnyone  = $a.hasClass('anyone');
            var isChecked = $a.hasClass('checked');

            // уже отмеченные дефолтный элемент либо радио-элемент: выходим
            if (isChecked && (isAnyone || radioMode)) return hide(200);
                
            // выбор действия
            var action = isAnyone ? 'reset' : (radioMode ? 'set' : (isChecked ? 'remove' : 'add'));

            $a.toggleClass('checked');
            $a.animate({backgroundColor: '#d93081'}, 100, function() {
                define[action](item);    
            });
        }

        hide(100);
    })
    .mouseleave(function() {
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

        var $dl = $(this);
        var d = (e.wheelDelta || -e.detail) > 0 ? 1 : -1;

        $dl.stop(true, true);

        var top = $dl.position().top + d * wheelStep();

        var max = $el.data('offset').top;
        var min = max - $el.data('height');

        if (top < max && top > min) $dl.animate({top: top}, 200);
    });

    // создаёт DOM-элемент отдельного значения
    function makeItem(item, checked, anyone) {
        var $a = $('<a/>').attr('href', '#').data('data', item).html(item.t);

        // отмеченное значение
        checked && $a.addClass('checked');

        // дефолтное значение
        anyone && $a.addClass('anyone');

        //var title = checked ? 'убрать «' + item.t + '»  из разрешённых' : 'добавить «' + item.t + '»  в разрешённые'
        //$a.attr('title', title);

        return $('<dd/>').append($a.append('<i/>'));
    };

    function show(values, offset) {
        $el.empty();
        
        $el.append($('<dt/>').text(define.options.title));

        $el.append(makeItem(define.anyone, define.has(), true));

        $.each(values, function(index, item) { 
            $el.append(makeItem(item, define.has(item), false));
        });

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
