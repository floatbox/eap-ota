$(function() {

    var tools = app.search.tools;
    var fields = app.search.fields; 
    var url = '/complete.json';
    
    // поле "Откуда"
    
    tools.from = $('#search-from').autocomplete({
        cls: 'autocomplete-gray',
        url: url,
        params: {
            input: 'from',
            limit: 30
        },
        root: 'data',
        loader: new app.Loader({
            parent: $('#search-from-loader')
        }),
        height: 374
        
    }).focus(function() {
        tools.from.reset.fadeOut(200);
    }).change(function() {
        app.search.update({from: $(this).val()}, this);
    });
    fields['from'] = tools.from.val();
    
    var fdata = tools.from.get(0).onclick();
    if (fdata && fdata.iata) {
        tools.from.trigger('iata', fdata.iata);
    }
    
    app.search.subscribe(tools.from, 'from', function(v) {
        tools.from.trigger('set', v);
    });
    
    // Ссылка для сброса поля "Откуда"
    
    tools.from.reset = $('#search-from-reset').click(function(e) {
        tools.from.focus().trigger('set', '');
    });

    // поле "Куда"
    
    tools.to = $('#search-to').autocomplete({
        // внешний вид
        cls: 'autocomplete',

        // ajax
        url: url,
        params: {
            input: 'to',
            limit: 30
        },
        root: 'data',
        loader: new app.Loader({
            parent: $('#search-to-loader')
        }),

        // размеры
        width: 340,
        height: 378
    }).change(function() {
        app.search.update({to: $(this).val()}, this);
    });
    fields['to'] = tools.to.val();

    app.search.subscribe(tools.to, 'to', function(v) {
        tools.to.trigger('set', v);
    });
    app.search.subscribe('ajax', 'date1', function(v) {
        var s = tools.to.val();
        var d = calendar.dates.eq(calendar.dmyindex[v]).text();
        var pattern = new RegExp('(\\s*)(?:сегодня|завтра|послезавтра|' + d + ')(\\s*)', 'i');
        var result = s.replace(pattern, function(s, p1, p2) {
            console.log(p1, p2, p1 && p2);
            return (p1 && p2) ? ' ' : '';
        });
        if (result != s) tools.to.trigger('set', result);
    });    
    
    
    // образец содержимого поля "Куда"
    
    var e = tools.to.example = $('#search-to-example');
    e.label = $('u', e);
    e.data  = e.label[0].onclick();
    e.data.current = 0;

    e.click(function(e) {
        e.preventDefault();
        e = e.target;

        if (e.tagName == 'S') with (tools.to.example) {
            data.current = ++data.current % data.length;
            e.className = 'animate';
            window.setTimeout(function(){e.className = ''}, 300);

            label.fadeTo(150, 0.4, function() {
                label.text(data[data.current]);
            }).fadeTo(150, 1);

            return;
        };

        if (e.tagName == 'U') {
            tools.to.focus();
            tools.to.trigger('set', e.innerHTML);
        };
    });

    // карта

    // какой там аналог у defined?()
    if (window['YMaps']) {
        var loc = YMaps.location || {},
            lat = loc.latitude || 45,
            lon = loc.longitude || 22;

        app.map = new app.Map({
            el: $('#where-map')[0],
            map: {
                lat: lat,
                lon: lon
            }
        });

        if (loc) {
            app.map.setPoint('from', {name: 'Вы&nbsp;&mdash;&nbsp;здесь', lat: lat, lon: lon});
        };
    }
    
    // Календарь
    
    var calendar = new app.Calendar("#search-calendar");
    fields['date1'] = undefined;
    fields['date2'] = undefined;
    app.search.subscribe(calendar, 'rt', function(v) {
        calendar.toggleOneway(v == 0);
    });
    app.search.subscribe(calendar, 'date1', function(v) {
        calendar.selected[0] = calendar.dmyindex[v];
        calendar.update();
    });
    app.search.subscribe(calendar, 'date2', function(v) {
        calendar.selected[1] = calendar.dmyindex[v];
        calendar.update();
    });
   
    // панель уточнений (фильтров)

    var data = {
        persons: [],

        changes: [
            {v: 1, t: 'ни одной'},
            {v: 2, t: 'можно с одной'}
        ],
        
        cls: [
            {v: 'Y', t: 'эконом-'},
            {v: 'C', t: 'бизнес-'},
            {v: 'F', t: 'первый '}
        ],

        dpt_time_0: [],
        arv_time_0: [],
        dpt_time_1: [],
        arv_time_1: [],

        dpt_airport_0: [],
        arv_airport_0: [],
        dpt_airport_1: [],
        arv_airport_1: [],
        
        cities: [],
        airlines: [],        
        planes: []
    };

    tools.defines = {};
    $('#search-define p').each(function() {
        var $define = $(this).define().trigger('update', data);
        var dname = $define.data('name');
        tools.defines[dname] = $define;
    });

    // обработка количества пассажиров
    tools.defines['persons'].bind('change', function() {
        var adults = 0, children = 0;
        var values = $(this).data('value');
        for (var i = 0; v = values[i]; i++) {
            var orig = values[i].v;
            var real = orig % (Math.floor(orig / 10) * 10);
            if (orig < 100) adults = real; else children += real;
        }
        app.search.update({
            'adults': adults,
            'children': children
        }, this);
    });
    
    // обработка пересадок
    tools.defines['changes'].bind('change', function() {
        var value = $(this).data('value')[0];
        if (app.offers.results.is(':visible')) {
            app.search.toggle(true);
            app.offers.update = {
                loading: true,
                action: function() {
                    var ao = app.offers;
                    ao.maxLayovers = value && value.v;
                    ao.resetFilters();
                    ao.applyFilter();
                }
            };
        } else {
            app.offers.maxLayovers = value && value.v;
        }
    });
    app.search.subscribe(tools.defines['changes'], 'changes', function(v) {
        tools.defines['changes'].trigger('select', v);
    });    

    // обработка класса
    fields['cabin'] = undefined;
    tools.defines['cls'].bind('change', function() {
        var value = $(this).data('value')[0];
        app.search.update({
            'cabin': value && value.v
        }, this);
    });
    app.search.subscribe(tools.defines['cls'], 'cabin', function(v) {
        tools.defines['cls'].trigger('select', v);
    });
    
    // рисуем "один взрослый"
    tools.defines['persons'].trigger('add', {v: 11, t: 'один'});

    // Фильтры предложений
    app.offers.filters = {};
    $('#offers-filter p').each(function() {
        var $filter = $(this).define().trigger('update', data);
        $filter.bind('change', function() {
            var values = $(this).data('value'), options = [];
            var name = $(this).data('name');
            for (var i = values.length; i--;) options.push(values[i].v);
            if (app.offers.filterable) app.offers.applyFilter(name, options);
        });
        app.offers.filters[$filter.data('name')] = $filter;
    });
    
    // Сброс фильтров
    $('#offers-reset-filters').click(function(event) {
        event.preventDefault();
        var ao = app.offers;
        ao.resetFilters();
        ao.applyFilter();
    });

    // составное поле "туда-обратно"
    var $retTabs = $('#search\\.ret\\.tabs').radio();
    var $retButton = $('#search\\.ret\\.button').button();

    // синхронизируем кнопку и табы
    tools.rt = new app.MultiField({'value': 'rt'});
    $retButton.trigger('subscribe', tools.rt);
    $retTabs.trigger('subscribe', tools.rt);
    tools.rt.subscribers.push({
        trigger: function(mode, v) {
            if (mode == 'set') {
                app.search.update({'rt': v == 'rt' ? 1 : 0}, tools.rt);
            }
        }
    });
    fields['rt'] = tools.rt.value == 'rt' ? 1 : 0;

    // вся эта хрень только для того, чтобы синхронизировать розовую рамку при ховере/фокусе
    // над табами "туда-обратно" и над полем "Куда"
        $retTabs.hover(
            function() {
                tools.to.trigger('mouseenter');
            }, 
            function() {
                tools.to.trigger('mouseleave');
            }
        ).click(function() {
            tools.to.focus();
        });

        tools.to.hover(
            function() {
                $retTabs.addClass('return-tabs-hover');
            }, 
            function() {
                $retTabs.removeClass('return-tabs-hover');
            }
        ).bind('focus', function() {
            $retTabs.addClass('return-tabs-focus');
        }).bind('blur', function() {
            $retTabs.removeClass('return-tabs-focus');
        });
    // - хрень закончилась ;)


    // затычка для сворачивания панели
    var $spanel = $('#search-panel');
    $('.panel-switch', $spanel).click(function() {
        var cl = 'collapsed', st = $spanel.hasClass(cl);
        $spanel.switchClass(st ? cl : '', st ? '' :cl, 300);
    });
    
    // кнопка отправки запроса
    $('#search-submit .b-submit').click(function(event) {
        event.preventDefault();
        if (!$(this).parent().hasClass('disabled')) {
            app.offers.show();
        }
    });    
    
    // Список предложений
    app.offers.init();
    
    // Фокус на поле ввода "Куда"
    tools.to.focus();
    
    // Запоминаем данные формы для сброса
    app.search.defvalues = $.extend({}, fields);
    
    /* Сброс по клику на логотипе */
    $('#logo').click(function() {
        var data = $.extend({}, fields);
        for (var key in data) data[key] = app.search.defvalues[key];
        app.search.update(data);
        app.offers.hide();
        window.location.hash = '';
    });

    // Сохраненные результаты
    var hash = window.location.hash.substring(1);
    if (hash) {
        var hashparts = hash.split(':');
        app.search.validate(hashparts[0]);
    }
    
    // Включение запросов валидации
    app.search.active = true;

});
