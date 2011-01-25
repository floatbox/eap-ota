(function() {

    search.init();
    offersList.init();

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
        offersList.resetFilters();
        offersList.applyFilter();
    });
    $('#offers-list').delegate('.reset-filters', 'click', function() {
        offersList.resetFilters();
        offersList.applyFilter();
    });
    
    // Сохраненные результаты
    pageurl.parse();
    if (pageurl.search) {
        search.validate(pageurl.search);
    } else {
        search.segments[0].to.focus();
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
    }).find('a').click(function(event) {
        event.preventDefault();
    });
    
    // Данные по умолчанию для сброса
    search.defvalues = {
        form_segments: [{from: search.segments[0].from.val()}],
        people_count: $.extend({}, search.persons.selected),
        rt: true
    };
    
    // Фон для лоадера
    preload('/img/offers/photo-search.jpg', '/img/offers/progress.gif');

    // Всплывающие подсказки
    hint.init();
    
})();
