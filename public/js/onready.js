$(function() {

    var tools = app.search.tools;
    var url = '/complete.json';
    
    // поле "Откуда"
    
    tools.from = $('#search-from').autocomplete({

        // внешний вид
        cls: 'autocomplete-gray',

        // ajax
        url: url,
        params: {
            input: 'from',
            limit: 30
        },
        root: 'data',
        loader: new app.Loader({
            parent: $('#search-from-loader')
        }),

        // размеры
        height: 374
    }).focus(function() {
        tools.from.reset.fadeOut(200);
    }).bind('enter', function() {
        app.search.update({from: $(this).val()}, this);
    });
    app.search.addField('from', true, tools.from.val());

    // "подпольная" ссылка для сброса поля "Откуда"
    
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
    }).bind('enter', function() {
        app.search.update({to: $(this).val()}, this);
    });
    app.search.addField('to', true);    

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
            tools.to.trigger('enter');
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
            app.search.tools.from.trigger('set', loc.city);
            app.map.setPoint('from', {name: 'Вы&nbsp;&mdash;&nbsp;здесь', lat: lat, lon: lon});
            // app.form.$from.trigger('keydown.autocomplete');
        };
    }
    
    // Календарь
    
    var calendar = new app.Calendar("#search-calendar");
    app.search.addField('date1', true);
    app.search.addField('date2', function(value) {
        var rt = app.search.fields['rt'];
        return value || !(rt && rt.value);
    });
    app.search.subscribe(calendar, 'rt', function(v) {
        calendar.toggleOneway(v == 0);
    });
    app.search.subscribe(calendar, 'date1', function(v) {
        calendar.dpt.val(v);
    });
    app.search.subscribe(calendar, 'date2', function(v) {
        calendar.ret.val(v);
    });
   
    // панель уточнений (фильтров)

    var data = {
        persons: [],

        changes: [
            {v: 1, t: 'ни одной'},
            {v: 2, t: 'можно с одной короткой'},
            {v: 3, t: 'можно с одной'}
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
        var values = $(this).trigger('get').data('value');
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
        var value = $(this).trigger('get').data('value')[0];
        app.search.update({
            'nonstop': value && value.v == 1 ? 1 : 0
        }, this);
    });

    // обработка класса
    tools.defines['cls'].bind('change', function() {
        var value = $(this).trigger('get').data('value')[0];
        app.search.update({
            'cabin': value && value.v
        }, this);
    });
    
    // рисуем "один взрослый"
    tools.defines['persons'].trigger('add', {v: 11, t: 'один'});

    // Фильтры предложений
    app.offers.filters = {};
    $('#offers-filter p').each(function() {
        var $filter = $(this).define().trigger('update', data);
        $filter.bind('change', function() {
            var values = $(this).trigger('get').data('value'), options = [];
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
        ao.filterable = false;
        for (var key in ao.activeFilters) {
            ao.filters[key].trigger('reset');
            delete(ao.activeFilters[key]);
        }
        ao.filterable = true;
        ao.applyFilter();
    });
    
    // верхние табы
    $('#search\\.mode').radio();

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
    app.search.addField('rt', false, tools.rt.value == 'rt' ? 1 : 0);

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
    
    // фокус на поле ввода "Куда"
    tools.to.focus();

// счётчик секунд; отладка
//app.timer = $('#offers-progress h4 i').timer();
//app.timer.trigger('start');

});




/*
app.obs = function(cfg) {
    $.extend(app.obs.prototype, {
        constructor: $.noop
    }, cfg || {});

    this.constructor();
    return this.constructor;
}

    // игрушка для градиента

    var wmap = $('#where\\.map');
    wmap.height = wmap.height();
    wmap.width = wmap.width();
    wmap.top = wmap.offset().top;
    wmap.left = wmap.offset().left;

    $.browser.mozilla && wmap.mousemove(function(e) {
        var y =  100 * (e.pageY - wmap.top) / wmap.height;
        var x =  100 * (e.pageX - wmap.left) / wmap.width;
        this.style.backgroundImage = '-moz-linear-gradient(top ' + (5 + x/y) + 'rad, #4b4b4b 10%, #d93c86 ' + (y-20) + '%, green ' + (y-10) + '%, blue ' + y + '%, yellow ' + (y+20) + '%, red, black)';
    })

    $.browser.mozilla && wmap.click(function(e) {
        l(this.style.backgroundImage);
        var y =  100 * (e.pageY - wmap.top) / wmap.height;
        var x =  100 * (e.pageX - wmap.left) / wmap.width;
        this.style.backgroundImage = '-moz-radial-gradient(' + x + '% ' + y + '%, circle farthest-side, #d93c86 0%, blue 100%)';
    })

*/

