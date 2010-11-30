var pageurl = {
parse: function() {
    var hash = window.location.hash.substring(1);
    if (hash) {
        var hparts = hash.split(':');
        this.search = hparts[0];
        this.tab = hparts[1] || 'featured';
        this.booking = hparts[3];
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
            this.payment && parts.push(this.payment);
        }
        var url = parts.join(':');
        window.location.hash = url;
        if (window._gaq) _gaq.push(['_trackPageview', '/#' + url]);
    } else {
        window.location.hash = '';
    }
    $(window).scrollTop(cst);
}
};
