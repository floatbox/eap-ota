/* Page */
var page = {
init: function() {
    this.header = $('#page-header');
    this.location.init();
    this.title.init();

    search.init();
    results.init();
    booking.init();
    User.init();    

    preloadImages('/images/search/dates.png');
    preloadImages('/images/results/progress.gif', '/images/results/fshadow.png', '/images/results/slider.png');
    preloadImages('/images/booking/progress-w.gif', '/images/booking/progress-b.gif');

    if (this.location.booking) {
        this.restoreBooking(this.location.search, this.location.booking);
    } else if (this.location.search === 'login') {
        search.map.resize();
        User.el.show();
        User.show('authorization');
        User.resetOnHide = true;
        this.loadLocation();
    } else if (this.location.search.indexOf('confirmation_token') == 0) {
        this.showConfirmationForm();
    } else if (this.location.search.indexOf('reset_password_token') == 0) {
        this.showPasswordForm();    
    } else if (this.location.search) {
        this.restoreResults(this.location.search);
    } else {
        search.map.resize();
        this.reset();
        this.loadLocation();
        _gaq.push(['_trackPageview']);
    }
    
    $(function() {
        if (browser.platform !== 'iphone') {
            $w.scrollTop(0);
        }
        if (search.map.el.is(':visible')) {
            search.map.load();
        }
    });
    
},
innerHeight: function() {
    return $w.height() - 62;
},
loadLocation: function() {
    $.get('/whereami', function(data) {
        var city = (data && data.city_name) || 'Москва';
        var dpt = search.locations.segments[0].dpt;
        if (dpt.field.val() === '') {
            dpt.set(city);
        }
        search.defaultValues.segments = [{dpt: city}];
    });
},
showConfirmationForm: function() {
    User.el.show();
    User.resetOnHide = true;
    var token = this.location.search.replace('confirmation_token=', '');
    $.ajax({
        method: 'GET',
        url: '/profile/confirmation',
        data: {confirmation_token: token},
        success: function(result) {
            if (result.success) {
                User.password.el.find('.phus-title').css('margin-bottom', '');
                User.password.el.find('.phupp-profile').html('для личного кабинета <strong>' + result.resource.email + '</strong>').show();
                User.password.use(token, 'confirmation_token', '/profile/confirm');
                User.show('password');
            } else {
                User.show('token');
            }
        },
        error: function() {
            User.show('token');
        },
        timeout: 20000
    });
    this.loadLocation();
    search.map.resize();
},
showPasswordForm: function() {
    User.el.show();
    User.resetOnHide = true;
    var token = this.location.search.replace('reset_password_token=', '');
    User.password.el.find('.phus-title').css('margin-bottom', '13px');
    User.password.el.find('.phupp-profile').hide();
    User.password.use(token, 'reset_password_token', '/profile/password');
    User.show('password');
    this.loadLocation();
    search.map.resize();
},
restoreResults: function(key) {
    search.el.hide();
    search.loadSummary({query_key: key});
    results.ready = false;
    results.message.toggle('loading');          
    results.filters.hide();
    results.show(true);
},
restoreBooking: function(rkey, bkey) {
    search.el.hide();
    search.loadSummary({query_key: rkey}, false);
    if (!browser.ios) {
        results.header.el.addClass('rh-fixed');
        page.header.addClass('fixed');    
    }    
    results.header.button.hide();
    results.header.select.show();
    results.filters.hide();    
    booking.key = bkey;
    booking.loading.show();
    booking.el.addClass('b-processing').show();
    booking.load();
    _kmq.push(['record', 'VISIT: variant']);
},
reset: function() {
    search.setValues(search.defaultValues);
    search.mode.select('rt');
    setTimeout(function() {
        search.waitRequests();
    }, 350);
    //search.mode.values.show();
    search.locations.focusEmpty();
},
showData: function(data) {
    var that = this;
    this.title.set(I18n.t('page.search', {title: data.titles.window}));
    if (this.location.search !== data.query_key) {
        this.location.set('search', data.query_key);
    }
}
};

/* Location */
page.location = {
init: function() {
    var that = this;
    if ('onhashchange' in window) {
        $(window).on('hashchange', function() {
            that.compare();
        });
    } else {
        setInterval(function() {
            that.compare();
        }, 500);
    }
    this.parse();
},
set: function(key, value) {
    this[key] = value;
    if (key === 'search') {
        delete this.offer;
        delete this.booking;
    }
    this.update();
},
compare: function() {
    var hash = window.location.hash;
    if (hash !== this.hash) {
        this.process();
    }
},
parse: function() {
    this.hash = window.location.hash;
    var parts = this.hash.substring(1).split('/'), p1 = parts[1];
    this.search = parts[0];
    if (p1 && p1.length === 24) {
        delete this.offer;
        this.booking = p1;
    } else {
        delete this.booking;
        this.offer = p1;
    }
},
process: function() {
    var s = this.search;
    var o = this.offer;
    var b = this.booking;
    this.parse();
    if (!this.search) {
        page.reset();
    } else if (this.search !== s) {
        page.restoreResults(this.search);
    } else if (!this.booking && b) {
        booking.cancel();
    } else if (this.offer !== o) {
        results.content.select(this.offer || 'all');
    }
},
update: function() {
    var parts = [];
    var st = $w.scrollTop();
    if (this.search) {
        parts.push(this.search);
    }
    if (this.booking) {
        parts.push(this.booking);
    } else if (this.offer) {
        parts.push(this.offer);
    }
    window.location.hash = parts.join('/');    
    this.hash = window.location.hash;
    $w.scrollTop(st);
},
track: function() {
    return '/#' + this.hash.replace('#', '');
}
};

/* Title */
page.title = {
init: function() {
    this.empty = document.title;
},
set: function(title) {
    document.title = title || this.empty;
}
};

/* Errors 
window.onerror = function(text) {
    var type;
    if (page.location.booking) {
        type = 'В форме бронирования';
    } else if (page.location.search) {
        type = 'В результатах поиска';
    } else {
        type = 'В форме поиска';
    }
    _gaq.push(['_trackEvent', 'Ошибка JS', type, text]);
}*/