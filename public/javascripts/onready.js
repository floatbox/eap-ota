(function() {

    search.init();
    results.init();
    results.filters.init();
    results.matrix.init();    

    // Сохраненные результаты
    pageurl.parse();
    if (pageurl.search) {
        search.validate(pageurl.search);
    } else {
        $('#promo').removeClass('latent');
        search.segments[0].to.focus();
    }
    
    // Сохраненное бронирование
    if (pageurl.booking) {
        app.booking.el = $('<div class="booking"></div>').appendTo($('#offers'));
        app.booking.load(pageurl.booking);
    }

    // Сброс по клику на логотипе
    $('#logo').click(function() {
        app.booking.unfasten();
        results.hide();
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
