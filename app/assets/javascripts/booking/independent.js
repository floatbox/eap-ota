/* Fixed header */
booking.initFixedHeader = function() {
    if (browser.scanty) return;
    var fixed = false;
    var canvas = $(window).scroll(function() {
        toggle();
    });
    var toggle = function() {
        var st = canvas.scrollTop();
        if (st > bhtop !== fixed) {
            fixed = st > bhtop;
            bheader.toggleClass('bh-static', !fixed);
        }
    };
    var bheader = $('#booking .booking-header');
    var bhtop = bheader.offset().top;
    $('#booking .bh-placeholder').height(bheader.height());
};

/* Booking form */
booking.init = function(partner) {
    var that = this;
    this.el = $('#booking');
    this.header = this.el.find('.booking-header');
    var path = window.location.path || window.location.pathname;
    var hash = window.location.hash.substring(1);
    this.query_key = path.split('/').last();
    if (hash.indexOf('recommendation') !== -1) {
        //window.location.hash = '';
        this.prebook(this.query_key, hash.match(/recommendation=([^&]+)/)[1]);
        this.partner = partner;
    } else if (hash.length !== 0) {
        this.load(hash);
    } else {
        window.location = '/#' + this.query_key;
    }
    this.updateLinks();
    this.el.find('.bh-title .stop-booking').addClass('latent');
};
booking.prebook = function(query_key, hash) {
    var that = this;
    this.request = $.ajax({
        url: '/booking/preliminary_booking?query_key=' + query_key + '&recommendation=' + hash + '&variant_id=1',
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
        number: number,
        load_variant: 1
    }, function(result) {
        window.location.hash = number;
        that.key = number;
        var bcontent = that.el.find('.booking-content').html(result);
        var bvariant = that.el.find('.booking-variant').html('');
        bvariant.append(bcontent.find('.offer-variant').removeClass('g-none'));
        $('#results-loading').addClass('latent');
        that.updateLinks('найти другой вариант');
        that.el.find('.bh-title .stop-booking').removeClass('latent');
        that.el.find('th.book .a-button').html('Купить').click(function(event) {
            event.preventDefault();
            $.animateScrollTop(bcontent.offset().top - $('#booking .booking-header').height());
        }).css('display', 'block');
        that.el.find('.booking-body').show();
        that.initFixedHeader();
        that.activate();
    });
};
booking.failed = function() {
    window.location = '/#' + this.query_key + '/reload';
    //$('#results-loading').addClass('latent');
    //$('#results-empty').removeClass('latent');
};
booking.updateLinks = function(rename) {
    var url = '/#' + this.query_key + '/featured';
    this.el.find('span.stop-booking').each(function() {
        var title = rename || $(this).html();
        var link = $('<a class="stop-booking"></a>').html(title).attr('href', url);
        $(this).replaceWith(link);
    });
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
