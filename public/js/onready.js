(function() {

    search.init();
    offersList.init();

    // составное поле "туда-обратно"
    var $retTabs = $('#search-ret-tabs').radio();
    var $retButton = $('#search-ret-button').button();

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
    
    // Фильтры предложений
    offersList.filters = {};
    $('#offers-filter .filter').each(function() {
        var f = new controls.Filter($(this));
        f.el.bind('change', function(e, values) {
            var name = $(this).attr('data-name');
            if (offersList.filterable) offersList.applyFilter(name, values);
        });
        offersList.filters[$(this).attr('data-name')] = f;
    });
    
    // Сброс фильтров
    $('#offers-reset-filters').click(function(event) {
        event.preventDefault();
        $(this).addClass('g-none');
        var ao = offersList;
        ao.resetFilters();
        ao.applyFilter();
    });    
    
    // Сохраненные результаты
    pageurl.parse();
    if (pageurl.search) {
        search.validate(pageurl.search);
    } else {
        search.to.focus();
    }
    
    /* Сохраненное бронирование */
    if (pageurl.booking) {
        app.booking.el = $('<div class="booking"></div>').appendTo(offersList.results);
        app.booking.load(pageurl.booking);
    }

    // Сброс по клику на логотипе
    $('#logo').click(function() {
        app.booking.unfasten();
        offersList.hide();
        pageurl.reset();
        pageurl.title();
        search.restore(search.defvalues || {});
    });
    
    // Данные по умолчанию для сброса
    search.defvalues = {
        from: search.from.val(),
        people_count: $.extend({}, search.persons.selected)
    };
    
})();
