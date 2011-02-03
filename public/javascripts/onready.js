(function() {

    search.init();
    offersList.init();

    // Фильтры предложений
    offersList.filters = {};
    $('#offers-filter .filter').each(function() {
        var f = new controls.Filter($(this));
        f.template = ': $';
        f.el.bind('change', function(e, values) {
            fixedBlocks.update();
            var name = $(this).attr('data-name');
            if (offersList.filterable) offersList.applyFilter(name, values);
        });
        offersList.filters[$(this).attr('data-name')] = f;
    });
    $('#offers-filter .expand-filters').click(function() {
        var filter = $('#offers-filter-content'), fh = filter.height();
        filter.children('.of-collapsed').hide();
        filter.children('.of-expanded').show();
        filter.css({
            height: fh,
            overflow: 'hidden'
        }).animate({
            height: filter.children('.of-expanded').height()
        }, 120, function() {
            $(this).css({
                height: 'auto',
                overflow: 'visible'
            });
        });
    });
    $('#offers-filter .collapse-filters').click(function() {
        var filter = $('#offers-filter-content');
        filter.css({
            height: filter.height(),
            overflow: 'hidden'
        }).animate({
            height: 30
        }, 120, function() {
            filter.children('.of-expanded').hide();
            filter.children('.of-collapsed').show();
            $(this).css({
                height: 'auto',
                overflow: 'visible'
            });
        });
    });
    
    // Фильтр количества пересадок
    var lf = offersList.filters['layovers'];
    lf.dropdown.removeClass('dropdown').addClass('vlist');
    lf.show = function() {};
    lf.hide = function() {};
    
    // Сброс фильтров
    $('#offers-filter .reset-filters').click(function(event) {
        event.preventDefault();
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
    
    // Сохраненное бронирование
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
    
    // Переключение блоков при прокрутке
    fixedBlocks.init();

})();
