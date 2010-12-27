/*
    TODO 

    чтобы фигачить дальше, т.к. нету
        - сервиса геолокации
        - разбора строки


    ВНЕШНИЙ ВИД
    + приаттачить градиент через data-uri
    + лого
    + IATA-код в списке

    - невалидное значение подчёркивать красным
    - плавное затухание правой границы
    - кратность общей высоты списка высоте отдельного элемента


    ПОВЕДЕНИЕ
    - прогресс вынести в отдельный класс; шаблон класса
    - в конструкторе объекта инициализивароть его из атрибута "onclick"
    - обновлять IATA-код(ы) после разборщика; несколько кодов

    - привесить обработчик мышиных событий, а также копипаста и драг&дропа
    - методы set/get, добавление в форму

    КОД

    КОСЯКИ
    * позиция списка при проскролленой строке в инпуте будет неопределена, увы
    * поебень с определением клавиши в макинтоше - не уверен, что стоит бороться
    - IE: почему-то остаётся пустая полоса от скроллбара
    - у Коли в ФФ не перекрывается розовая рамка поля ввода
    - табуляция при закрытом спсике почему-то перестала переводить фокус в другое поле

    ИДЕИ
    - может и закэшированные цены тоже показывать?

*/

// Depends:
//  jquery.ui.core.js

;(function($) {
    
$.fn.extend({

    autocomplete: function(options) {
        options = options || {};

        options = $.extend({}, {

            // оформление
            cls: 'autocomplete',
            hoverCls: 'autocomplete-hover',
            focusCls: 'autocomplete-focus',
            loadCls: 'autocomplete-load',
            listCls: 'autocomplete-list',
            listDimCls: 'autocomplete-list-dim',
            listHoverCls: 'hover',

            iataCls: 'iata',

            // размеры
            height: 369,
            width: $(this).outerWidth() - 2,
            scroll: true,

            // запрос данных
            dataType: 'jsonp',
            delay: 300,
            params: {},
            loader: null,

            // поведение
            autoFill: true,

            item: function(data) {return data.name}
        }, options);

        return this.each(function() {
            new $.Autocompleter(this, options);
        });
    },

    selection: function(start, end) {
        if (start !== undefined) {
            return this.each(function() {
                if( this.createTextRange ){
                    var selRange = this.createTextRange();
                    if (end === undefined || start == end) {
                        selRange.move("character", start);
                        selRange.select();
                    } else {
                        selRange.collapse(true);
                        selRange.moveStart("character", start);
                        selRange.moveEnd("character", end);
                        selRange.select();
                    }
                } else if( this.setSelectionRange ){
                    this.setSelectionRange(start, end);
                } else if( this.selectionStart ){
                    this.selectionStart = start;
                    this.selectionEnd = end;
                }
            });
        }
        var field = this[0];
        if ( field.createTextRange ) {
            var range = document.selection.createRange(),
                orig = field.value,
                teststring = "<->",
                textLength = range.text.length;
            range.text = teststring;
            var caretAt = field.value.indexOf(teststring);
            field.value = orig;
            this.selection(caretAt, caretAt + textLength);
            return {
                start: caretAt,
                end: caretAt + textLength
            }
        } else if( field.selectionStart !== undefined ){
            return {
                start: field.selectionStart,
                end: field.selectionEnd
            }
        }
    }
});

/* =======  Поле ввода  ======== */

$.Autocompleter = function(input, options) {

    var $el = $(input).attr('autocomplete', 'off');

    $el.data('options', options);

    options.cls && $el.addClass(options.cls);

    var timeout;
    var hasFocus = 0;
    var keyCode;

    var select = $.Autocompleter.List(input, insert);
    var $iata = $.Autocompleter.IATA($el);

    var cache = {};

    var blockSubmit;
    // prevent form submit in opera when selecting with return key
    $.browser.opera && $(input.form).bind("submit.autocomplete", function() {
        if (blockSubmit) {
            blockSubmit = false;
            return false;
        }
    });
    
    // отслеживание изменений
    var storedValue = $el.val();
    var compareTimer;
    var compare = function() {
        var value = $el.val();
        if (value != storedValue) {
            storedValue = value;
            $el.trigger('change');
        }
    };
    var setCompareTimer = function(ms) {
        clearInterval(compareTimer);
        compareTimer = setInterval(compare, ms);
    };
    setCompareTimer(4500);

    // only opera doesn't trigger keydown multiple times while pressed, others don't work with keypress at all
    $el.bind(($.browser.opera ? "keypress" : "keydown") + ".autocomplete", function(event) {
        var KEY = $.ui.keyCode;

        // a keypress means the input has focus
        // avoids issue where input had focus before the autocomplete was applied
        hasFocus = 1;
        // track last key pressed
        
        keyCode = event.which;

        switch(keyCode) {
            case KEY.UP:
                event.preventDefault();
                select.visible() ? select.prev() : keypress();
                break;
                
            case KEY.DOWN:
                event.preventDefault();
                select.visible() ? select.next() : keypress();
                break;
                
            case KEY.PAGE_UP:
                event.preventDefault();
                select.visible() ? select.pageUp() : keypress();
                break;
                
            case KEY.PAGE_DOWN:
                event.preventDefault();
                select.visible() ? select.pageDown() : keypress();
                break;

            case KEY.RIGHT:
                if (insert({cursorAtTheEnd: true})) {
                    event.preventDefault();
                }
                else {
                    clearTimeout(timeout);
                    timeout = setTimeout(keypress, options.delay);
                }
                break;
               
            case KEY.ENTER:
                event.preventDefault();
            
            case KEY.TAB:
                // stop default to prevent a form submit, Opera needs special handling
                blockSubmit = true;
                if (insert()) {
                    event.preventDefault();
                    return false;
                }
                break;
                
            case KEY.ESCAPE:
                event.preventDefault();
                select.hide();
                break;

            // shift, ctrl, alt
            case KEY.SHIFT:
            case KEY.CONTROL:
            case 18:
                break;
            default:
                clearTimeout(timeout);
                timeout = setTimeout(keypress, options.delay);
                break;
        }

    }).focus(function() {
        hasFocus++;
        $el.addClass(options.focusCls);
        $iata.update(); // надо поменять цвет подложки
        setCompareTimer(300);
        setTimeout(function() {
            $el.select();
        }, 10);
    }).blur(function() {
        hasFocus = 0;
        hideResults();
        $el.removeClass(options.focusCls);
        $iata.update();
        setCompareTimer(4500);
    }).click(function() {
        if (hasFocus++ > 1 && !select.visible()) keypress();
    }).bind('set', function(e, s) {
        storedValue = s;
        $el.val(s);
        $el.trigger('change');
        if (!s) $iata.hide();
    }).bind('iata', function(e, v) {
        $iata.show(v);
    });
    
    options.hoverCls && $el.hover(
        function() {
            $el.addClass(options.hoverCls);
        }, 
        function() {
            $el.removeClass(options.hoverCls);
        }
    );

    // обработчик клавиатурного события

    function keypress() {
        var params = {
            val: $el.val(),
            pos: $el.selection().start
        }

        // не отсылаем запрос для пустой строки или нулевой позиции
        if (params.pos) {
            var data = cache['' + params.pos + params.val];
            data ? process(data) : request(params, process, hideResultsNow);
        } else {
            options.loader && options.loader.hide();
            select.hide();
        }
    };

    // запрос к серверу

    function request(params) {
        options.loader && options.loader.show();

        select.dim();

        $.extend(params, options.params);

        $.ajax({
            url: options.url,
            data: params,
            dataType: options.dataType,

            success: function(data) {
                options.loader && options.loader.hide();
                select.undim();

                var key = read(data);
                process(cache[key], key);
            }
        });
    };

    // чтение приехавших данных; заполнение кэша

    function read(data) {
        var key = '' + data.stat.pos + data.stat.val;

        data = options.root && data[options.root] || data;

        cache[key] = [];
        for (var i = 0; i < data.length; i++) cache[key].push(data[i]);

        return key;
    };

    // показ выпадающего списка

    function process(data, key) {
        var total = data && data.length;

        var val = $el.val();
        var cur = $el.selection().start;

        // эти данные подходят текущему состоянию инпута?
        if (key && key != '' + cur + val) return;

        if (total && hasFocus) {
            select.fill(data);

            // SHIT минимум левой границы можно не искать, достаточно data[0].start
            var start = data[0].start,
                i= total;
            while (i--) start = Math.min(start, data[i].start);

            var left = offset(val.slice(0, start));

            select.show(left);

            options.autoFill && autoFill(data);
        } else {
            hideResultsNow();
        }
    };

    // вычисляет длину текстовой строки в пикселах

    function offset(s) {
        if (s == '') return 0;
        $el.ruler = $el.ruler || $('<div/>').addClass('ruler').appendTo($el.parent());
        return $el.ruler.text(s).width();
    };

    // втыкаем единственное соответствие (если нажата не управляющая кнопка, то есть человек вводит текст)

    function autoFill(data) {
        if (data.length != 1) return;

        // нажата небуквенная клавиша: автокомплитить не надо
        // вторая проверка для блядского макинтоша, там оба кода == 0
        if (keyCode <= $.ui.keyCode.DELETE && keyCode != 0) return;

        insert({
            data: data[0],
            cursorAtTheEnd: true,
            autoFill: true
        });
    };

    // вставка значения в инпут; позиционирование курсора

    function insert(params) {
        params = $.extend({
            data: null, // данные для подстановки, иначе берём текущий элемент списка
            cursorAtTheEnd: false, // подстановка разрешена, только если курсор находится в конце слова
            autoFill: false // режим автоподстановки, когда только одно подходящее значение
        }, params);

        var val = $el.val();
        var cur = $el.selection().start;

        var data = params.data || select.current();
        if (!data) return false;

        if (params.cursorAtTheEnd) {
            // курсор в середине слова? не подставляем
            if (/\S/.test(val.substr(cur, 1))) return false;
        } 
            
        // если такое значение в инпуте уже есть, то снимаем выделение, прячем список и выходим
        if (val.indexOf(data.insert) >= 0) {
            var sel = $el.selection();
            $el.selection(sel.end, sel.end);

            hideResultsNow();
            return true;
        }

        var s = [val.slice(0, data.start), val.slice(data.start, data.end), val.slice(data.end)];

        // заполняем инпут новой строкой
        $el.val(s[0] + data.insert + s[2]);

        $iata.show(data.entity.iata);

        // нужно ли подсветить вставленный фрагмент?
        // только при автоподстановке с побуквенным совпадением вставки и замещения (нельзя MOW -> Москва)
        var hl = params.autoFill && match(data.insert, s[1]);
        var end = data.start + data.insert.length;

        hl ? $el.selection(cur, end): $el.selection(end, end);

        // если автоподстановка, то список не прячем
        params.autoFill || hideResultsNow();

        $el.trigger('enter');
        return true;
    };

    function match(ins, rep) {
        var re = /[^a-zа-яё]/g;
        ins = ins.toLowerCase().replace(re, ' ');
        rep = rep.toLowerCase().replace(re, ' ');
        return ins.indexOf(rep) == 0;
    };

    function hideResults() {
        clearTimeout(timeout);
        timeout = setTimeout(hideResultsNow, 200);
    };

    function hideResultsNow() {
        clearTimeout(timeout);
        options.loader && options.loader.hide();
        select.hide();
    };
};

/* =======  Выпадающий список  ======== */

$.Autocompleter.List = function(input, insert) {
    var $input = $(input);
    var options = $input.data('options');

    var $box, $list, items, status, maxleft;
    var active = -1;

    
    (function init() {
        $box = $('<div/>')
        .hide()
        .addClass(options.listCls)
        .css({
            position: 'absolute',
            width: options.width
        })
        .appendTo(document.body);
        
        $list = $('<ul/>')
        .appendTo($box)
        .mouseover(function(e) {
            e = e.target;
            if (e.tagName != 'LI') return;

            active = $('li', $list).index(e);

            items.removeClass(options.listHoverCls);

            e = $(e);
            e.addClass(options.listHoverCls);
            setStatus(e);
        })
        .click(function(e) {
            var d = data(e);
            if (!d) return;

            // щёлкнули по IATA или ещё куда, показываем объект на карте
            // todo: 1) переделать как метода app.map 2) искать лбые гео.объекты 
            // 3) задавать яндексу область поиска (напр, для аэропорта - город и страну)

            var isGeo = (d.entity.type == 'country' && e.target.tagName == 'I') || (d.entity.type == 'city' && e.target.tagName == 'B');
            if (isGeo && app.map) { 
                var geo = new YMaps.Geocoder(d.entity.name);
                YMaps.Events.observe(geo, geo.Events.Load, function () {
                    if (this.length()) with (app.map.map) {
                        var g = this.get(0).getGeoPoint();
                        openBalloon(g, d.entity.name);
                        panTo(g, {flying: 1});
                    }
                });
                return false;
            }

            insert({data: d});
            input.focus();
            return false;
        });

        status = $('<p/>')
        .appendTo($box)
        .data('default', '<b>&#8593;&#8595;</b> движение, <b>&#8629;</b> выбор');

        // это одноразовая функция
        // arguments.callee = $.noop;

    })();
    
    function data(e) {
        e = e.target;
        while (e.parentNode && e.tagName != 'LI') e = e.parentNode;
        return e.tagName == 'LI' ? $.data(e, 'data') : null;
    }

    function setStatus(li) {
        var h = li && (li.data('data').entity.info || li.data('data').name.bold());
        status.html(li ? h : status.data('default'));
    }

    function moveSelect(step) {
        items.slice(active, active + 1).removeClass(options.listHoverCls);
        movePosition(step);
        var activeItem = items.slice(active, active + 1).addClass(options.listHoverCls);

        if(options.scroll) {
            var offset = 0;
            items.slice(0, active).each(function() {
                offset += this.offsetHeight;
            });
            if((offset + activeItem[0].offsetHeight - $list.scrollTop()) > $list[0].clientHeight) {
                $list.scrollTop(offset + activeItem[0].offsetHeight - $list.innerHeight());
            } else if(offset < $list.scrollTop()) {
                $list.scrollTop(offset);
            }
        }

        setStatus(activeItem);
    };
    
    function movePosition(step) {
        active += step;
        if (active < 0) {
            active = items.size() - 1;
        } else if (active >= items.size()) {
            active = 0;
        }
    }
    
    function fill(data) {
        $list.empty();
        active = 0;

        for (var i = 0; i < data.length; i++) {
            var $li = $.Autocompleter.List.Item(data[i]).appendTo($list);
            i == active && $li.addClass(options.listHoverCls);
        }
        items = $list.find('li');

        $.fn.bgiframe && $list.bgiframe();
    }
    
    return {
        fill: function(data) {
            fill(data);
            status[data.length > 1 ? 'removeClass' : 'addClass']('g-none');
            setStatus();
        },
        next: function() {
            moveSelect(1);
        },
        prev: function() {
            moveSelect(-1);
        },
        pageUp: function() {
            if (active != 0 && active - 8 < 0) {
                moveSelect( -active );
            } else {
                moveSelect(-8);
            }
        },
        pageDown: function() {
            if (active != items.size() - 1 && active + 8 > items.size()) {
                moveSelect( items.size() - 1 - active );
            } else {
                moveSelect(8);
            }
        },

        show: function(left) {
            var me = this;

            var offset = $input.offset();
            if (maxleft === undefined) {
                maxleft = $input.outerWidth() - $box.outerWidth();
            }
            left = Math.min(left || 0, maxleft);

            $box.css({
                top: offset.top + input.offsetHeight - 1,
                left: offset.left + left
            }).delay(0);
            
            me.visible() || $box.animate(
                {
                    height: ['show', 'easeInOutQuart'],
                    // width: options.width,
                    opacity: ['show', 'easeInOutQuart']
                },
                200,
                'linear',
                function() {
                    me.undim();
                }
            );

            if (options.scroll) {
                $list.scrollTop(0);
                $list.css({
                    maxHeight: options.height,
                    overflow: 'auto'
                });
                
                if($.browser.msie && typeof document.body.style.maxHeight === "undefined") {
                    var listHeight = 0;
                    items.each(function() {
                        listHeight += this.offsetHeight;
                    });
                    var scrollbarsVisible = listHeight > options.height;
                    $list.css('height', scrollbarsVisible ? options.height : listHeight );
                    if (!scrollbarsVisible) {
                        // IE doesn't recalculate width when scrollbar disappears
                        items.width( $list.width() - parseInt(items.css("padding-left")) - parseInt(items.css("padding-right")) );
                    }
                }
            }
        },

        hide: function() {
            this.visible() && $box && $box.animate(
                {
                    height: ['hide', 'easeInOutQuart'],
                    //width: options.width / 2,
                    opacity: 'hide'
                },
                150,
                'linear',
                function() {
                    items && items.removeClass(options.listHoverCls);
                    active = -1;
                }
            );
        },

        dim: function() {
            items && items.length > 1 && $box.addClass(options.listDimCls);
        },

        undim: function() {
            $box.removeClass(options.listDimCls);
        },

        visible : function() {
            return $box && $box.is(":visible");
        },

        // возвращает данные подсвеченного элемента, если таковой есть
        current: function() {
            var selected = items && items.filter("." + options.listHoverCls);
            return selected && selected.length && $.data(selected[0], 'data');
        },
        emptyList: function (){
            $list && $list.empty();
        }
    };
};

/* =======  Элемент списка  ======== */

$.Autocompleter.List.Item = function(data) {

    function hl(name, hl) {
        hl = data.hl.split(' ');
        while (hl[0]) name = name.replace(new RegExp('(' + hl.pop() + ')', 'i'), '<~>$1</~>');
        return name.replace(/~/g, 'u');
    }

    var render = {
        'default': function(e) {
            return {hint: e.hint || '', code: null, cls: null}
        },
        airport: function(e) {
            return {hint: e.hint || '', code: e.iata, cls: null}
        },
        city: function(e) {
            return {hint: e.hint, code: e.iata, cls: null}
        },
        country: function(e) {
            var i = app.constant.countries.length - 1;
            while (i && app.constant.countries[i] != data.entity.iata.toLowerCase()) i--;
            // i хранит номер флага в панорамной картинке countries.png
            return {hint: e.hint || '', code: i, cls: 'country'}
        },
        date: function(e) {
            return {hint: e.hint || '', code: null, cls: 'date'}
        },
        persons: function(e) {
            return {hint: e.hint || '', code: null, cls: 'persons'}
        },
        comfort: function(e) {
            return {hint: e.hint || 'комфорт', code: null, cls: null}
        },
        aircraft: function(e) {
            return {hint: e.hint || 'тип самолёта', code: null, cls: null}
        },
        pivo: function(e) {
            return {hint: e.hint || 'развлечения', code: null, cls: 'pivo'}
        },
        fun: function(e) {
            return {hint: e.hint || 'развлечения', code: null, cls: 'fun'}
        }
    }

    var $li  = $('<li/>');

    var s  = hl(data.name, data.hl);
    $('<u/>').html(s).appendTo($li);

    var r = render[data.entity.type] || render['default'];

    with (r(data.entity)) {
        hint && $('<s/>').html(hint).appendTo($li.append('<wbr/>'));
        
        cls && $li.addClass(cls).append($('<i/>'));

        if (code) if (cls == 'country')
            $('i', $li).css('background-position', '0 ' + -9 * --code + 'px');
        else
            $('<b/>').html(code).appendTo($li);

    }

    return $li.data('data', data);
};

// IATA-код текущего объекта

$.Autocompleter.IATA = function($input) {
    var title = 'IATA-код, принятый в авиации';
    var o = $input.data('options');
    var $el = $('<div/>').append('<i/>').append($('<u/>')).addClass(o.iataCls).appendTo($input.parent());
    var $text = $('u', $el);
    function update() {
        $('*', $el).css('backgroundColor', $input.css('backgroundColor'));
    }
    update();
    return {
        show: function(v, t) {
            $el.show();
            $text.text(v || '');
            $text.attr('title', t || title);
        },

        hide: function() {
            $el.hide();
        },

        update: update
    }
};

})(jQuery);
