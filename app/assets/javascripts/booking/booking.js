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
},
abort: function() {
    if (this.request && this.request.abort) {
        this.request.abort();
        delete this.request;
    }
    if (this.temporary) {
        this.temporary.remove();
        delete this.temporary;
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
    offer.state.html('<span class="ob-progress">Проверяем доступность мест</span>');
    if (!offer.details || offer.details.is(':hidden')) {
        offer.showDetails();
    }
    $w.smoothScrollTo(offer.details.offset().top - 52 - 36 - 92);
    trackEvent('Бронирование', 'Предварительное бронирование');    
    this.variant = offer.selected;
    this.offer = offer;
},
process: function(result) {
    if (result && result.success) {
        this.key = result.number;
        if (false && result.price !== this.variant.price) {
            this.offer.book.hide();
            this.updatePrice(result.price);
        } else {
            this.load();
        }
    } else {
        this.failed();
    }
},
updatePrice: function(price) {
    var dp = price - this.variant.price;
    var sum = results.currencies['RUR'].absorb('<span class="ob-sum">' + Math.abs(dp) + '</span>');
    this.temporary = $('#ob-price-change').clone().removeAttr('id');
    this.temporary.find('.obpc-title').html(function(i, template) {
        return template.absorb(dp > 0 ? 'дороже' : 'дешевле', sum);
    });
    trackEvent('Бронирование', 'Изменилась цена', dp > 0 ? 'Стало дороже' : 'Стало дешевле');
    this.offer.el.append(this.temporary);
    this.variant.price = price;
    if (this.offer.complex) {
        this.variant.offer.updateBook();
        this.offer.countPrices();
        this.offer.otherPrices();
    }
},
failed: function() {
    var tip = 'Так иногда бывает, потому что авиакомпания не&nbsp;может подтвердить наличие мест на&nbsp;этот рейс по&nbsp;этому тарифу. К&nbsp;сожалению, от&nbsp;нас это не&nbsp;зависит. Спасибо за&nbsp;понимание.';
    this.offer.state.html('В данный момент невозможно выбрать этот вариант <span class="link obs-hint">Почему?</span>');
    this.offer.state.find('.obs-hint').click(function(event) {
        hint.show(event, tip);
    });
    trackEvent('Бронирование', 'Невозможно выбрать вариант');
},
load: function() {
    var that = this;
    this.request = $.get('/booking/?number=' + this.key, function(content) {
        page.location.set('booking', that.key);
        if (results.data) {
            page.title.set(local.title.booking.absorb(results.data.titles.window));
        }
        results.header.edit.hide();
        results.header.select.show();
        if (that.offer) {
            that.preview(content)
        } else {
            that.view(content);
        }
    });
},
view: function(content) {
    this.content.html(content);
    this.content.find('.os-details').addClass(function(i) {
        return 'segment' + (i + 1);
    });
    this.loading.hide();
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
    if (this.temporary) {
        delete this.temporary.remove();
    }
    this.el.show();
    $w.scrollTop(0);
    this.form.init();    
    this.farerules.init();
    $w.delay(100).queue(function(next) {
        results.filters.hide(true);
        Queries.hide();
        next();
    });
    $w.delay(400).smoothScrollTo(this.form.position());
},
cancel: function() {
    Queries.show();
    results.filters.show(true);
    results.header.select.hide();
    if (results.ready) {
        var that = this;
        this.offer.showDetails(true);
        $w.smoothScrollTo(0).delay(50).queue(function(next) {
            that.hide();
            next();
        });
    } else {
        this.el.hide();
        this.content.html('');        
        delete this.offer;
        results.message.toggle('loading');          
        results.show(true);
        results.load();
    }
    trackEvent('Бронирование', 'Отмена бронирования');    
},
hide: function() {
    var offset = this.content.find('.b-details').offset().top - $w.scrollTop();
    this.el.hide().removeClass('b-processing');
    this.content.html('');
    this.loading.hide();
    results.header.edit.show();
    results.content.el.show();
    $w.scrollTop(this.offer.details.offset().top - offset);
    page.title.set(local.title.results.absorb(results.data.titles.window));
    page.location.set('booking');
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
    var translator = google && google.translate && google.translate.SectionalElement.getInstance();
    if (translator && translator.update) {
        translator.update();
    }
},
show: function() {
    trackEvent('Бронирование', 'Просмотр правил тарифа');
    this.el.slideDown(350);
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
