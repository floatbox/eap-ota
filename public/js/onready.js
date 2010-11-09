$(function() {

    search.init();
    
    // образец содержимого поля "Куда"
    var e = search.to.example = $('#search-to-example');
    e.label = $('u', e);
    e.data  = e.label[0].onclick();
    e.data.current = 0;
    e.click(function(e) {
        e.preventDefault();
        e = e.target;
        if (e.tagName == 'S') with (search.to.example) {
            data.current = ++data.current % data.length;
            e.className = 'animate';
            window.setTimeout(function(){e.className = ''}, 300);
            label.fadeTo(150, 0.4, function() {
                label.text(data[data.current]);
            }).fadeTo(150, 1);
            return;
        }
        if (e.tagName == 'U') {
            search.to.focus();
            search.to.trigger('set', e.innerHTML);
        }
    });      

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
    
    // составное поле "туда-обратно"
    var $retTabs = $('#search\\.ret\\.tabs').radio();
    var $retButton = $('#search\\.ret\\.button').button();

    // Синхронизация кнопки и табов
    search.rt = new app.MultiField({'value': 'rt'});
    $retButton.trigger('subscribe', search.rt);
    $retTabs.trigger('subscribe', search.rt);
    search.rt.subscribers.push({
        trigger: function(mode, v) {
            if (mode == 'set') {
                search.calendar.toggleOneway(v != 'rt');
                search.update();
            }
        }
    });

    // Синхронизация розовой рамки при ховере/фокусе
    $retTabs.hover(
        function() {
            search.to.trigger('mouseenter');
        }, 
        function() {
            search.to.trigger('mouseleave');
        }
    ).click(function() {
        search.to.focus();
    });

    search.to.hover(
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
    
    // Список предложений
    app.offers.init();
    
    // Фильтры предложений
    app.offers.filters = {};
    $('#offers-filter .filter').each(function() {
        var f = new controls.Filter($(this));
        f.el.bind('change', function(e, values) {
            var name = $(this).attr('data-name');
            if (app.offers.filterable) app.offers.applyFilter(name, values);
        });
        app.offers.filters[$(this).attr('data-name')] = f;
    });
    
    // Сброс фильтров
    $('#offers-reset-filters').click(function(event) {
        event.preventDefault();
        var ao = app.offers;
        ao.resetFilters();
        ao.applyFilter();
    });    
    
    // Фокус на поле ввода "Куда"
    search.to.focus();

    // Сохраненные результаты
    var hash = window.location.hash.substring(1);
    if (hash) {
        var hashparts = hash.split(':');
        app.search.validate(hashparts[0]);
    }

    // Сброс по клику на логотипе
    $('#logo').click(function() {
        app.booking.unfasten();
        app.offers.hide();
        window.location.hash = '';
    });    
    
    // Включение запросов валидации
    app.search.active = true;

});
