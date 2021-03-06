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
        this.cancel();
    }
}
booking.prebook = function(query_key, hash, partner, marker) {
    var that = this;
    this.request = $.ajax({
        type: 'POST',
        url: '/booking',
        data: { query_key: query_key, recommendation: hash, partner: partner, marker: marker },
        success: function(result) {
            if (result && result.success) {
                if (result.partner_logo_url) {
                    $('#parther-logo').html('<img src="' + result.partner_logo_url + '" alt="">').closest('.bd-column').show();
                }
                _kmq.push(['record', 'PRE-BOOKING: success']);
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
    this.request = $.get('/booking/' + number, function(content) {
        window.location.hash = number;
        that.view(content);
        var price = decoratePrice(I18n.t('currencies.RUR', {count: Number(that.content.find('.bf-newprice').attr('data-price'))}));
        var button = $('#obb-template');
        var priceTemplate = '<div class="obbt-sum">{0}</div><div class="obbt-buy">' + I18n.t('offer.price.buy') + '</div>';
        button.find('.obb-title').html(priceTemplate.absorb(price)).click(function() {
            $w.smoothScrollTo(that.form.el.offset().top);
            $w.queue(function(next) {
                $('#bfp0-last-name').focus();
                next();
            });
        });
        if (price_changed) {
            var newprice = that.content.find('.bf-newprice').addClass('bf-newprice-top');
            var tickets = that.content.find('.bfp-table').attr('data-total') === '1' ? 'билет' : 'билеты';
            that.content.find('.b-header').before(newprice);
            newprice.find('.bfnp-content .link').click(function() {
                that.cancel();
            });
            newprice.show();
            _kmq.push(['record', 'PRE-BOOKING: price changed']);
            _gaq.push(['_trackPageview', '/booking/price_rising']);
        }
        that.content.find('.b-header').prepend(button);
        that.content.find('.bffc-link').html('выбрать другой вариант');
        that.content.delegate('.od-alliance', 'click', function(event) {
            var el = $(this);
            hint.show(event, 'В альянс ' + el.html() + ' входят авиакомпании: ' + el.attr('data-carriers') + '.');
        });
        $('#booking-disclaimer').prependTo(that.content).show();
    });
};
booking.failed = function() {
    _kmq.push(['record', 'PRE-BOOKING: fail']);
    var that = this;
    setTimeout(function() {
        that.cancel();
    }, 500);
};
booking.cancel = function() {
    window.location = '/#' + this.query_key;
};
