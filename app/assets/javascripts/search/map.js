/* Map */
search.map = {
init: function() {
    this.el = $('#search-map');
    this.control = this.el.find('.smap-control');
    this.content = this.el.find('.smap-content');
    this.content.css('top', -Math.round(this.margin / 2));
    this.wrapper = $('#search-wrapper');
    if (!browser.ios) {
        this.bindResize();
    }
    var that = this;
    this.control.click(function() {
        if (search.dates.el.hasClass('sd-hidden')) {
            that.slideUp();
        } else {
            that.slideDown();
        }
    });
    this.colors = ['#81aa00', '#db7100', '#0aa0c6'];
    this.items = [];
},
bindResize: function() {
    var that = this;
    $w.bind('resize', function() {
        if (that.el.is(':visible')) that.resize();
    });
},
resize: function(instant) {
    var dh = 36; // Page header
    dh += search.locations.el.height();
    dh += search.dates.el.height() + 2;
    dh += search.options.el.height();
    dh += results.header.height;
    if (Queries.height) {
        dh += Queries.height - 2;
    }
    var mh = $w.height() - dh;
    if (mh < 63 != this.collapsed) {
        this.collapsed = mh < 63;
        this.control.toggleClass('smc-collapsed', this.collapsed);
    }
    this.content.height(Math.max(30, mh));
    this.toggleZoom(mh);
    if (this.api && this.bounds) {
        this.fitBounds();
    }
},
toggleZoom: function(h) {
    var zoomVisible = h > 80;
    if (this.api && zoomVisible !== this.zoomVisible) {
        this.api.setOptions({zoomControl: zoomVisible}); 
        this.zoomVisible = zoomVisible;
    }
},
load: function() {
    if (typeof google !== 'undefined' && google.maps) {
        extendOverlayPrototype();
        this.defpoint = new google.maps.LatLng(55.751463, 37.621651);
        this.api = new google.maps.Map(this.content.get(0), {
            zoom: 4,
            center: this.defpoint,
            backgroundColor: '#ccd8b1',
            mapTypeId: google.maps.MapTypeId.TERRAIN,
            disableDefaultUI: true,
            zoomControl: this.content.height() > 80,
            zoomControlOptions: {
                style: google.maps.ZoomControlStyle.SMALL
            },
            scrollwheel: false,
            minZoom: 2,
            maxZoom: 8
        });
        this.bounds = this.defpoint;
        if (this.deferred) {
            this.show(this.deferred);
            delete this.deferred;
        }
        this.load = $.noop;
    }
},
slideDown: function() {
    var that = this;
    var wh = this.wrapper.height();
    var ch = this.content.height();
    var dh = wh - ch - search.dates.tlheight;
    this.wrapper.height(wh).css('overflow', 'hidden');
    this.control.removeClass('smc-collapsed');
    this.content.animate({
        height: ch + dh
    }, 300, function() {
        search.dates.toggleHidden(true);
        google.maps.event.trigger(that.api, 'resize');
        that.wrapper.height('').css('overflow', '');
        that.control.html('Свернуть карту');
        that.toggleZoom(ch + dh);
        that.fitBounds();
    });
    search.dates.el.find('.sdt-tab').delay(150).fadeOut(150);
},
slideUp: function() {
    var that = this;
    var wh = this.wrapper.height();
    this.wrapper.height(wh).css('overflow', 'hidden');
    search.dates.toggleHidden(false);
    var ch = search.dates.el.height();
    var dh = ch - search.dates.tlheight;
    this.toggleZoom(wh - ch);
    this.content.animate({
        height: wh - ch
    }, 300, function() {
        google.maps.event.trigger(that.api, 'resize');
        that.wrapper.height('').css('overflow', '');
        that.control.toggleClass('smc-collapsed', that.collapsed);
        that.control.html('Развернуть карту');
        that.fitBounds();
    });
    search.dates.el.find('.sdt-tab').fadeIn(150);
},
show: function(segments) {
    this.clean();
    var points = [];
    var pindex = {};
    var processPoint = function(p, s, t) {
        if (!p) return;
        if (!pindex[p.name]) {
            p.type = t;
            p.segment = s;
            p.latlng = new google.maps.LatLng(p.lat, p.lng);
            pindex[p.name] = p;
            points.push(p);
        } else if (pindex[p.name].type = 'arv') {
            pindex[p.name].segment = s;
        }
        return pindex[p.name].latlng;
    };
    for (var i = 0, im = segments.length; i < im; i++) {
        var s = segments[i];
        var dpt = processPoint(s.dpt, i + 1, 'dpt');
        var arv = processPoint(s.arv, i + 1, 'arv');
        if (dpt && arv) {
            var route = new google.maps.Polyline({
                geodesic: true,
                path: [dpt, arv],
                strokeColor: this.colors[i],
                strokeOpacity: 0.9,
                strokeWeight: 1,
                map: this.api
            });
            this.items.push(route);
        }
    }
    var bounds = new google.maps.LatLngBounds();
    for (var i = 0, im = points.length; i < im; i++) {
        var point = points[i];
        /*var marker = new google.maps.Marker({
            position: point.latlng,
            title: point.name,
            map: this.api
        });*/
        var label = new mapLabel({
            position: point.latlng,
            title: point.name,
            map: this.api
        });        
        bounds.extend(point.latlng);
        this.items.push(label);
    }
    if (points.length > 1) {
        this.bounds = bounds;
    } else {
        this.bounds = points[0].latlng || this.defpoint;
    }
    this.fitBounds();
},
fitBounds: function() {
    if (this.bounds.getCenter) {
        this.api.fitBounds(this.bounds);
    } else {
        this.api.setCenter(this.bounds);
        this.api.setZoom(5);
    }
},
clean: function() {
    for (var i = this.items.length; i--;) {
        this.items[i].setMap(null);
    }
    this.items.length = 0;
}
};

/* Custom marker */
function mapLabel(opts) {
    this.$el = $('<div class="sm-label"></div>');
    this.$el.html(opts.title + '<div class="smla-shadow"></div><div class="sml-arrow"></div>');
    this.setValues(opts);
    this.setMap(opts.map);
}

function extendOverlayPrototype() {
    mapLabel.prototype = new google.maps.OverlayView();
    mapLabel.prototype.onAdd = function() {
        this.getPanes().floatPane.appendChild(this.$el.get(0));        
    };
    mapLabel.prototype.draw = function() {
        var projection = this.getProjection();
        var position = projection.fromLatLngToDivPixel(this.get('position'));
        this.$el.css({
            left: position.x - Math.round(this.$el.outerWidth() / 2) - 6,
            top: position.y - this.$el.outerHeight() - 16
        });
    };    
    mapLabel.prototype.onRemove = function() {
        this.$el.remove();
    };    
}