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
        };
    });

    // карта

    if (YMaps) {
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
   
    // панель уточнений (фильтров)

    var data = {
        persons: [],

        aircompany: [
            {v: 4, t: 'Херофлот, СССР'},
            {v: 1, t: 'Air Berlin, Германия'},
            {v: 2, t: 'Alitalia, Италия'},
            {v: 3, t: 'CCM Airlines, Франция'}
        ],

        changes: [
            {v: 1, t: 'ни одной'},
            {v: 2, t: 'можно с одной короткой'},
            {v: 3, t: 'можно с одной'}
        ],

        timeDept: [
            {v: 1, t: '"рабочее" время (9..21 h)'},
            {v: 4, t: 'утро'},
            {v: 2, t: 'день'},
            {v: 5, t: 'вечер'},
            {v: 3, t: 'ночь'}
        ],

        airportDept: [
            {v: 2, t: 'Внуково'},
            {v: 3, t: 'Шереметьево'},
            {v: 4, t: 'Домоседово'},
            {v: 1, t: 'Быково'},
            {v: 6, t: 'Коровино'},
            {v: 5, t: 'Нижнее Задолгое'}
        ],

        timeArrv: [
            {v: 1, t: '"светлое" время (9..21 h)'},
            {v: 4, t: 'утро'},
            {v: 2, t: 'день'},
            {v: 5, t: 'вечер'},
            {v: 3, t: 'ночь'}
        ],

        airportArrv: [
            {v: 1, t: 'Альборг'},
            {v: 2, t: 'Альтенрейн'},
            {v: 3, t: 'Бирмингем'},
            {v: 4, t: 'Благовещенск'},
            {v: 5, t: 'Бордо'},
            {v: 6, t: 'Дюнкерк'},
            {v: 7, t: 'Клайпеда'},
            {v: 8, t: 'Бирмингем'},
            {v: 9, t: 'Благовещенск'},
            {v: 10, t: 'Бордо'},
            {v: 11, t: 'Неаполь'}
        ],

        aircraft: [
            {v: 1, t: 'Boeing 737-800'}
            /*
            ,{v: 2, t: 'Ан-2'},
            {v: 3, t: 'Concorde'},
            {v: 4, t: 'Airbus A300'},
            {v: 5, t: 'Embraer ERJ-145'}
            */
        ],

        cls: [
            {v: 1, t: 'эконом-'},
            {v: 2, t: 'бизнес-'},
            {v: 3, t: 'первый '}
        ]
    };

    var define = $('#search\\.define');
    var defines = $('p', define).define();
    defines.trigger('update', data);


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
	app.search.addField('rt');
	app.search.update({'rt': tools.rt.value == 'rt' ? 1 : 0}, tools.rt);

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

    // фокус на поле ввода "Куда"
    tools.to.focus();
    
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
