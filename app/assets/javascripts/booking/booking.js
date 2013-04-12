/* Booking */
var booking = {
init: function() {
    var that = this;
    this.el = $('#booking');
    this.content = this.el.find('.b-content');
    this.loading = this.el.find('.b-loading');
    validator.names = {
        m: ' ' + genderNames.m.toLowerCase() + ',',
        f: ' ' + genderNames.f.toLowerCase() + ','
    };
    results.header.select.find('.rhs-link').click(function() {
        that.cancel();
    });
    this.content.delegate('.bf-hint', 'click', function(event) {
        var content = $('#' + $(this).attr('data-hint')).html();
        hint.show(event, content);
    });
    this.content.delegate('.od-alliance', 'click', function(event) {
        var el = $(this);
        hint.show(event, 'В альянс ' + el.html() + ' входят авиакомпании: ' + el.attr('data-carriers') + '.');
    });
},
abort: function() {
    clearTimeout(this.ltimer);
    if (this.request && this.request.abort) {
        this.request.abort();
        delete this.request;
    }
    if (this.offer) {
        this.offer.book.removeClass('ob-disabled').show();
        this.offer.updateBook();
    }
    delete this.variant;
    delete this.offer;
},
prebook: function(offer) {
    var that = this;
    var params = {
        query_key: results.data.query_key,
        recommendation: offer.selected.id
    };
    this.abort();
    this.request = $.ajax({
        url: '/booking/preliminary_booking?' + $.param(params),
        success: function(data) {
            that.process(data);
        },
        error: function() {
            that.failed();
        },
        timeout: 60000
    });
    offer.book.addClass('ob-disabled');
    offer.state.html('<span class="ob-progress">' + I18n.t('prebooking.progress') + '</span>');
    if (!offer.details || offer.details.is(':hidden')) {
        offer.showDetails();
    }
    $w.smoothScrollTo(offer.details.offset().top - 52 - 36 - 92);
    this.variant = offer.selected;
    this.offer = offer;
    _kmq.push(['record', 'RESULTS: variant selected']);
    _kmq.push(['record', 'RESULTS: ' + results.content.selected + ' variant selected']);
    _gaq.push(['_trackEvent', 'Бронирование', 'Выбор варианта']);
},
process: function(result) {
    var that = this;
    if (result && result.success) {
        this.offer.state.html(I18n.t('prebooking.available'));
        this.key = result.number;
        this.ltimer = setTimeout(function() {
            that.load();
        }, 1000);
        _kmq.push(['record', 'PRE-BOOKING: success']);
    } else {
        this.failed();
    }
},
failed: function() {
    var tip = 'Так бывает вследствие несвоевременного или&nbsp;некорректного обновления авиакомпанией информации о&nbsp;наличии мест в&nbsp;системах бронирования. К&nbsp;сожалению, от&nbsp;нас это не&nbsp;зависит. Спасибо за&nbsp;понимание.';
    this.offer.book.addClass('ob-failed');
    this.offer.state.html('Авиакомпания не подтвердила наличие мест по этому тарифу. Выберите <span class="obs-cancel">другой вариант</span>. <span class="link obs-hint">Почему так бывает?</span>');
    this.offer.state.find('.obs-hint').click(function(event) {
        hint.show(event, tip);
    });
    _kmq.push(['record', 'PRE-BOOKING: fail']);
    _gaq.push(['_trackEvent', 'Бронирование', 'Невозможно выбрать вариант']);    
},
load: function() {
    var that = this;
    this.request = $.get('/booking/?number=' + this.key, function(content) {
        page.location.set('booking', that.key);
        if (results.data) {
            page.title.set(I18n.t('page.booking', {title: results.data.titles.window}));
        }
        results.header.edit.hide();
        results.header.select.show();
        if (that.offer) {
            that.preview(content)
        } else {
            that.view(content);
        }
        /*$w.delay(400).smoothScrollTo(that.form.position());
        $w.queue(function(next) {
            $('#bfp0-last-name').focus();
            next();
        });*/
        _gaq.push(['_trackPageview', '/booking']);
        _yam.hit('/booking');
    });
},
view: function(content) {
    this.content.html(content);
    this.content.find('.os-details').addClass(function(i) {
        return 'segment' + (i + 1);
    });
    this.loading.hide();
    this.content.show();
    this.el.removeClass('b-processing').show();
    this.form.init();
    this.farerules.init();
    $w.scrollTop(0);
},
preview: function(content) {
    var that = this;
    this.content.html(content);
    this.content.find('.os-details').addClass(function(i) {
        return 'segment' + (i + 1);
    });
    results.content.el.hide();
    this.offer.book.removeClass('ob-disabled');
    this.offer.updateBook();
    this.comparePrices();
    this.el.show();
    $w.scrollTop(0);
    this.form.init();
    this.farerules.init();
    $w.delay(100).queue(function(next) {
        results.filters.hide(true);
        next();
    });
},
comparePrices: function() {
    var that = this;
    var context = this.content.find('.bf-newprice');
    var dp = Number(context.attr('data-price')) - this.variant.price;
    if (dp !== 0) {
        context.show();
        context.find('.bfnp-content .link').click(function() {
            that.cancel();
        });
        _kmq.push(['record', 'PRE-BOOKING: price changed']);
        _gaq.push(['_trackEvent', 'Бронирование', 'Изменилась цена', dp > 0 ? 'Стало дороже' : 'Стало дешевле']);            
    }
},
processPrice: function(context, dp) {
    var sum = I18n.t('currencies.RUR', {count: Math.abs(dp)});
    var content = context.find('.bfnp-content');
    content.html(content.html().absorb(dp > 0 ? 'дороже' : 'дешевле', sum));
},
cancel: function() {
    results.filters.show(true);
    results.header.select.hide();
    if (results.ready) {
        var that = this;
        this.offer.showDetails(true);
        this.hide();
    } else {
        this.el.hide();
        this.content.html('');
        delete this.offer;
        page.location.set('booking');
        results.message.toggle('loading');
        results.show(true);
        results.load();
    }
    _gaq.push(['_trackEvent', 'Бронирование', 'Отмена бронирования']);
},
hide: function() {
    var offset = this.content.find('.b-details').offset().top - $w.scrollTop();
    this.el.hide().removeClass('b-processing');
    this.content.html('');
    this.loading.hide();
    results.header.edit.show();
    results.content.el.show();
    $w.scrollTop(this.offer.details.offset().top - offset);
    $w.delay(300).smoothScrollTo(Math.max(this.offer.el.offset().top - 36 - results.header.height - 90, 0));
    page.title.set(I18n.t('page.results', {title: results.data.titles.window}));
    page.location.set('booking');
    _gaq.push(['_trackPageview', page.location.track()]);
    _yam.hit(page.location.track());
    delete this.offer;
}
};

/* Farerules */
booking.farerules = {
init: function() {
    var that = this;
    this.el = booking.el.find('.bf-farerules');
    this.el.find('.bff-close').click(function() {
        that.hide();
    });
    this.el.find('.bffg-content').each(function() {
        var content = $(this);
        content.html(content.html().replace(/\n/gm, '<br>'));
    });
    booking.el.find('.bffd-farerules').click(function(event) {
        that.show();
    });
    if (typeof google !== 'undefined' && google.translate) {
        var instance = google.translate.SectionalElement.getInstance();
        if (instance && instance.update) {
            instance.update();
        }
    } else {
        var gt = document.createElement('script'); gt.type = 'text/javascript'; gt.async = true;
        gt.src = '//translate.google.com/translate_a/element.js?cb=googleSectionalElementInit&ug=section&hl=ru';
        var st = document.getElementsByTagName('script')[0]; st.parentNode.insertBefore(gt, st);
    }
},
show: function() {
    this.el.slideDown(350);
    _kmq.push(['record', 'BOOKING: fare rules displayed']);
    _gaq.push(['_trackEvent', 'Бронирование', 'Просмотр правил тарифа']);  
},
hide: function() {
    this.el.slideUp(350);
}
};

function googleSectionalElementInit() {
    new google.translate.SectionalElement({
        sectionalNodeClassName: 'bff-group',
        controlNodeClassName: 'bffg-translate',
        background: 'transparent'
    }, 'google_sectional_element');
}
