/* Results */
var search = {};

/* Booking form */
booking.restore = function() {
    var path = window.location.path || window.location.pathname;
    var hash = window.location.hash.substring(1);
    this.query_key = path.split('/').last();
    if (hash.indexOf('recommendation') !== -1) {
        // авиасейлз зачем-то дорисовывает вопросик после partner=
        var partner = hash.match(/partner=([^&?]+)/);
        var marker = hash.match(/marker=([^&?]+)/);
        this.prebook(this.query_key, hash.match(/recommendation=([^&?]+)/)[1], partner ? partner[1] : '', marker ? marker[1] : '');
    } else if (hash.length !== 0) {
        this.load(hash);
    } else {
        window.location = '/#' + this.query_key;
    }

}
booking.prebook = function(query_key, hash, partner, marker) {
    var that = this;
    this.request = $.ajax({
        url: '/booking/preliminary_booking?query_key=' + query_key + '&recommendation=' + hash + '&partner=' + partner + '&marker=' + marker + '&variant_id=1',
        success: function(result) {
            if (result && result.success) {
                that.load(result.number, result.changed_booking_classes);
            } else {
                that.failed();
            }
        },
        error: function() {
            that.failed();
        },
        timeout: 60000
    });
},
booking.load = function(number, price_changed) {
    var that = this;
    this.request = $.get('/booking/', {
        number: number
    }, function(content) {
        window.location.hash = number;
        that.view(content);
        var units = local.currencies.RUR;
        var price = Number(that.content.find('.bf-newprice').attr('data-price')).decline(units[0], units[1], units[2]);
        var button = $('#obb-template');
        button.find('.obb-title').html(local.offers.price.buy.absorb(price)).click(function() {
            $w.smoothScrollTo(that.form.el.offset().top);
            $w.queue(function(next) {
                $('#bfp0-first-name').focus();
                next();
            });
        });
        if (price_changed) {
            var newprice = that.content.find('.bf-newprice').addClass('bf-newprice-top');
            that.content.find('.b-header').before(newprice);
            newprice.find('.bfnp-content').html('Новая стоимость — ' + price);
            newprice.show();
            trackPage('/booking/price_rising');
        }
        that.content.find('.b-header').prepend(button);
        that.content.find('.bffc-link').html('выбрать другой вариант');
        that.content.delegate('.od-alliance', 'click', function(event) {
            var el = $(this);
            hint.show(event, 'В альянс ' + el.html() + ' входят авиакомпании: ' + el.attr('data-carriers') + '.');
        });            
        results.subscription.init($('#booking-subscription'));
        $('#booking-disclaimer').prependTo(that.content).show();
    });
};
booking.failed = function() {
    this.cancel();
};
booking.cancel = function() {
    window.location = '/#' + this.query_key;
};

/* Errors */
window.onerror = function(text) {
    trackEvent('Ошибка JS', 'При переходе с метапоиска', text);
}