﻿$(function() {

    search.init();
    offersList.init();

    // кнопка отправки запроса
    $('#search-submit .b-submit').click(function(event) {
        event.preventDefault();
        if (!$(this).parent().hasClass('disabled')) {
            clearTimeout(search.loadTimer);
            if (search.loadOptions) {
                offersList.load(search.loadOptions.options, search.loadOptions.title);
                delete(search.loadOptions);            
            }
            offersList.show();
        }
    });
    
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
    
    // Карта
    var fdata = search.from.get(0).onclick() || {lat: 55.751463, lng: 37.621651};
    if (typeof VEMap != 'undefined') {
        search.map = new VEMap('bingmap');
        search.map.SetCredentials('AtNWTyXWDDDWemqtCdOBchagXymI0P5Sh14O7GSlQpl2BJxBm_xn6YRUR7TPhJD0');
        search.map.SetDashboardSize(VEDashboardSize.Tiny);
        search.map.LoadMap(new VELatLong(fdata.lat, fdata.lng), 4);
        search.map.SetScaleBarDistanceUnit(VEDistanceUnit.Kilometers);
        search.updateMap(fdata);
    }

    /*search.map = new google.maps.Map($('#where-map').get(0), {
        mapTypeControl: false,
        streetViewControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        center: new google.maps.LatLng(fdata.lat, fdata.lng),
        zoom: 4
    });*/
    
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

    // Сброс по клику на логотипе
    $('#logo').click(function() {
        app.booking.unfasten();
        offersList.hide();
        pageurl.reset();
        search.restore(search.defvalues || {});
    });
    
    // Данные по умолчанию для сброса
    search.defvalues = {
        from: search.from.val(),
        people_count: $.extend({}, search.persons.selected)
    };
    
});

/* Detect browser */
var browser = (function() {
    var os = navigator.platform.toLowerCase().match(/mac|win|linux|ipad|iphone/);
    var agent = navigator.userAgent.toLowerCase().match(/safari|opera|msie \d|firefox|chrome/);
    agent = agent && agent[0].replace(/\s/, '');
    var browser = os && agent ? os + "-" + agent : undefined;
    if (agent == 'msie6') try {document.execCommand('BackgroundImageCache', false, true);} catch(e) {}
    if (browser) $(document.documentElement).addClass(browser);
    return browser;
})();

