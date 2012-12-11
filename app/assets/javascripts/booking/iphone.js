var trackPage = function(url) {
};
var trackEvent = function(category, action, label) {
};

/* Search */
var search = {};

/* Results */
var results = {
updateTitles: function(dates) {
    var wparts = [];
    var hparts = [];
    var year = search.dates.csnow.getFullYear();
    var yearUsed = false;
    if (this.data && this.data.segments) {
        for (var i = 0, l = this.data.segments.length; i < l; i++) {
            var segment = this.data.segments[i];
            var date = Date.parseDMY(dates ? dates[i] : segment.date);
            var title = segment.rt ? 'обратно' : segment.title;
            var hdate = date.human(!yearUsed && date.getFullYear() !== year && (yearUsed = true));
            hparts[i] = title.replace(/(^из| в) /g, '$1&nbsp;') + ' ' + hdate.nowrap();
            wparts[i] = title + ' на ' + hdate;
        }
        if (this.data.options.human) {
            hparts.push(this.data.options.human);
        }
    }
    this.data.titles = {
        header: hparts.join(', ').capitalize(),
        window: wparts.join(', ')
    };
    document.title = lang.pageTitle.booking.absorb(this.data.titles.window);
    $('#results-header .rh-summary').html(this.data.titles.header);
}
};

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
    this.content.on('click', '.bf-hint', function(event) {
        var content = $('#' + $(this).attr('data-hint')).html();
        hint.show(event, content);
    });
},
restore: function() {
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
        this.failed();
    }
},
prebook: function(query_key, hash, partner, marker) {
    var that = this;
    this.request = $.ajax({
        dataType: 'json',
        url: '/booking/preliminary_booking?query_key=' + query_key + '&recommendation=' + hash + '&partner=' + partner + '&marker=' + marker + '&variant_id=1',
        success: function(result) {
            that.failed();
            return;
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
load: function(number, price_changed) {
    var that = this;
    this.request = $.ajax({
        url: '/booking/',
        data: {
            number: number,
            iphone: true
        },
        success: function(content) {
            window.location.hash = number;
            that.loading.hide();
            that.content.html(content).show();
            that.el.removeClass('b-processing').show();
            that.form.init();
            that.farerules.init();
            if (price_changed) {
                that.content.find('.bf-newprice').show();
            }
        },
        error: function() {
            that.failed();
        },
        timeout: 60000
    });
},
failed: function() {
    this.loading.find('.bl-title').html('Авиакомпания не подтвердила наличие мест по этому тарифу');
    this.loading.find('.bl-tip').html('Выберите другой вариант');
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
    booking.el.find('.bffd-farerules').click(function(event) {
        that.show();
    });
},
show: function() {
    var st = $w.scrollTop();
    this.el.show();
    $w.scrollTop(st).smoothScrollTo(this.el.offset().top - 50);
},
hide: function() {
    this.el.hide();
}
};
