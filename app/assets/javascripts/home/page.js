/* Page */
var page = {
init: function() {
    this.header = $('#page-header');
    this.location.init();
    this.title.init();

    Queries.init();
    search.init();
    results.init();
    booking.init();

    preloadImages('/images/search/dates.png');
    preloadImages('/images/results/progress.gif', '/images/results/fshadow.png', '/images/results/slider.png');
    preloadImages('/images/booking/progress-w.gif', '/images/booking/progress-b.gif');
    
    if (this.location.booking) {
        this.restoreBooking(this.location.search, this.location.booking);
    } else if (this.location.search) {
        this.restoreResults(this.location.search);
    } else {
        search.map.resize();
        this.reset();
    }
    
    $(function() {
        $w.scrollTop(0);
        if (search.map.el.is(':visible')) {
            search.map.load();
        }
    });
    
    /*results.message.toggle('loading');
    results.content.el.show();
    results.show();*/

},
innerHeight: function() {
    return $w.height() - 36 - Queries.height;
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
        Queries.live.active = false;
        Queries.el.hide();
    }    
    results.header.button.hide();
    results.header.select.show();
    results.filters.hide();    
    booking.key = bkey;
    booking.loading.show();
    booking.el.addClass('b-processing').show();
    booking.load();
},
reset: function() {
    search.setValues(search.defaultValues);
    search.mode.select('rt');
    setTimeout(function() {
        search.waitRequests();
    }, 350);
    search.mode.values.show();
    search.locations.focusEmpty();
},
showData: function(data) {
    var that = this;
    setTimeout(function() { // задержка, чтобы синхронизировать появление таба с прокруткой окна
        Queries.history.add(data.query_key, data.short);
        Queries.history.select(data.query_key);
    }, 300);
    this.title.set(local.title.search.absorb(data.titles.window));
    this.location.set('search', data.query_key);
}
};

/* Location */
page.location = {
init: function() {
    var that = this;
    /*setInterval(function() {
        that.compare();
    }, 1000);*/
    this.hash = window.location.hash;
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
        this.hash = hash;
        this.process();
    }
},
parse: function() {
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
    this.hash = window.location.hash = parts.join('/');
    $w.scrollTop(st);
    //search.share.obj.updateShareLink(window.location.href, document.title);
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
