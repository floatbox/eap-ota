var pageurl = {
parse: function() {
    var hash = window.location.hash.substring(1);
    if (hash) {
        var hparts = hash.split(':');
        this.search = hparts[0];
        this.tab = hparts[1] || 'featured';
        this.booking = hparts[2];
    }
},
update: function(key, value) {
    var current = this[key];
    if (current != value) {
        this[key] = value;
        if (key == 'search') delete(this.booking);
        if (key == 'booking') delete(this.payment);        
        this.show();
    }
},
reset: function() {
    delete(this.search);
    delete(this.booking);
    this.show();
},
show: function() {
    var cst = $(window).scrollTop();
    if (this.search) {
        var parts = [this.search, this.tab];
        if (this.booking) {
            parts.push(this.booking);
        }
        var url = parts.join(':');
        window.location.hash = url;
        if (window._gaq) {
            _gaq.push(['_trackPageview', '/#' + url]);
        }
        this.summary = url;
    } else {
        window.location.hash = '';
        this.summary = '';
    }
    if (search.share.obj) {
        search.share.obj.updateShareLink(window.location.href, document.title);
    }
    $(window).scrollTop(cst);
},
title: function(t) {
    document.title = 'Eviterra — ' + (t || 'авиабилеты по всему миру онлайн');
}
};
