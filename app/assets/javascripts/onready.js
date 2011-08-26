var initHome = function() {

    // Браузеры с упрощенными эффектами
    browser.scanty = (browser.platform.search(/ipad|iphone/) !== -1 || browser.name.search(/safari|chrome|firefox|msie9/) === -1);

    // Инициализация блоков
    search.init();
    results.init();
    results.filters.init();
    results.matrix.init();
    results.diagram.init();
    booking.init();

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
        if (booking.el.is(':visible')) {
            booking.hide();
        }
        results.hide();
        pageurl.reset();
        pageurl.title();
        search.history.show();
        search.restore(search.defvalues || {});
        search.segments[0].to.focus();
        $(window).scrollTop(0);
    }).find('a').click(function(event) {
        event.preventDefault();
    });

    // Сохраненное бронирование
    if (pageurl.booking) {
        booking.load(pageurl.booking);
        booking.restored = true;
    }

    // Данные по умолчанию для сброса
    search.defvalues = {
        segments: [{from: search.segments[0].from.val()}],
        people_count: {adults: 1, children: 0, infants: 0},
        cabin: 'Y',
        rt: true
    };

    // Вкладки с сохраненными поисками
    search.history.init();

    // Восстановление результатов
    if (pageurl.search) {
        search.validate(pageurl.search);
    } else {
        $('#promo').removeClass('latent');
        search.persons.select({adults: 1, children: 0, infants: 0});
        search.cabin.select('Y');
        search.history.toggle(true);
        search.live.toggle(true);
        search.segments[0].to.focus();
    }

    // Всплывающие подсказки
    hint.init();

    /* Определение координат
    function show_map(position) {
      var latitude = position.coords.latitude;
      var longitude = position.coords.longitude;
    }

      function get_location() {
        navigator.geolocation.getCurrentPosition(show_map);
      }

      $(function() {
        get_location();
      });
*/
    // Генератор google plusone
      window.___gcfg = {lang: 'ru'};

      (function() {
        var po = document.createElement('script'); 
        po.type = 'text/javascript'; po.async = true;
        po.src = 'https://apis.google.com/js/plusone.js';
        var s = document.getElementsByTagName('script')[0];
        s.parentNode.insertBefore(po, s);
      })();
};
