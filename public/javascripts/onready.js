(function() {

    // Браузеры с упрощенными эффектами
    browser.scanty = (browser.platform.search(/ipad|iphone/) !== -1 || browser.name.search(/msie6|msie7|opera/) !== -1);

    // Инициализация блоков
    search.init();
    results.init();
    results.filters.init();
    results.matrix.init();
    results.diagram.init();

    // Данные по умолчанию для сброса
    search.defvalues = {
        form_segments: [{from: search.segments[0].from.val()}],
        people_count: $.extend({}, search.persons.selected),
        rt: true
    };

    // Обработка ссылки
    pageurl.init();

    // Переключение блоков при прокрутке
    fixedBlocks.init();

    // Прямой эфир
    search.live.init();

    // Фон для лоадера
    preload('/img/offers/photo-search.jpg', '/img/offers/progress.gif');

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

    // Один пассажир и эконом по умолчанию

    // Сохраненное бронирование
    if (pageurl.booking) {
        app.booking.el = $('<div class="booking"></div>').appendTo($('#offers'));
        app.booking.load(pageurl.booking);
    }

    // Восстановление результатов
    if (pageurl.search) {
        search.validate(pageurl.search);
    } else {
        $('#promo').removeClass('latent');
        search.persons.select({adults: 1, children: 0, infants: 0});
        search.cabin.select('Y');
        search.live.toggle(true);
        search.segments[0].to.focus();
    }

    // Всплывающие подсказки
    hint.init();

})();
