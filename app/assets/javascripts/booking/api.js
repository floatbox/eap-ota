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
                that.load(result.number);
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
booking.load = function(number) {
    var that = this;
    this.request = $.get('/booking/', {
        number: number
    }, function(content) {
        window.location.hash = number;
        that.view(content);
        that.content.find('.bffc-link').html('выбрать другой вариант');
        that.content.delegate('.od-alliance', 'click', function(event) {
            var el = $(this);
            hint.show(event, 'В альянс ' + el.html() + ' входят авиакомпании: ' + el.attr('data-carriers') + '.');
        });            
        results.subscription.init($('#booking-subscription').appendTo(that.content).show());
        $('#booking-disclaimer').prependTo(that.content).show();
    });
};
booking.failed = function() {
    this.cancel();
};
booking.cancel = function() {
    window.location = '/#' + this.query_key;
};
booking.form.track = function(result) {
    var path = window.location.href;
    if (window._gaq) {
        var price = booking.el.find('.booking-content .booking-price .sum').attr('data-value');
        _gaq.push(['_trackPageview', '/booking/success']);
        _gaq.push(['_addTrans', result.find('.pnr').text(), '', price]);
        _gaq.push(['_trackTrans']);
    }
    if (window.yaCounter5324671) {
        yaCounter5324671.hit('/booking/success');
    }
};
