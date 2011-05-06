search.map = {
init: function() {
    this.parent = search;
    this.colors = ['#81aa00', '#C46F26', '#0aa0c6'];
    var that = this;
    if (typeof google !== 'undefined' && google.maps) {
        var f = search.segments[0].from.get(0).onclick();
        this.defpoint = new google.maps.LatLng(55.751463, 37.621651);
        this.obj = new google.maps.Map($('#map-canvas').get(0), {
            zoom: 5,
            center: (f && f.lat && f.lng) ? new google.maps.LatLng(f.lat, f.lng) : that.defpoint,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            streetViewControl: false,
            mapTypeControl: false,
            scrollwheel: false
        });
        this.lines = [];
        if (this.deferred) {
            this.show(this.deferred);
            delete(this.deferred);
        }
        this.active = true;
    }
},
show: function(segments) {
    this.clean();
    var lines = [], pins = [], pindex = {};
    for (var i = 0, im = segments.length; i < im; i++) {
        var f = segments[i].from, t = segments[i].to;
        var fp = f && f.lat && f.lng && new google.maps.LatLng(f.lat, f.lng);
        var tp = t && t.lat && t.lng && new google.maps.LatLng(t.lat, t.lng);
        if (fp && !pindex[f.code]) {
            pindex[f.code] = true;
            pins.push(fp);
        }
        if (tp && !pindex[t.code]) {
            pindex[t.code] = true;
            pins.push(tp);
        }
        if (fp && tp) {
            lines.push({
                points: [fp, tp],
                color: this.colors[i]
            });
        }
    }
    var isrt = (this.parent.mode === 'rt');
    for (var i = 0, im = lines.length; i < im; i++) {
        var route = new google.maps.Polyline({
            geodesic: true,
            path: lines[i].points,
            strokeColor: lines[i].color,
            strokeOpacity: (isrt && i === 1) ? 0.5 : 0.9,
            strokeWeight: 3
        });
        this.lines.push(route);
        route.setMap(this.obj);
    }
    if (pins.length > 1) {
        var bounds = new google.maps.LatLngBounds();
        for (var i = pins.length; i--;) {
            bounds.extend(pins[i]);
        }
        this.obj.fitBounds(bounds);
    } else {
        this.obj.setCenter(pins[0] || this.defpoint);
        this.obj.setZoom(5);
    }
},
clean: function() {
    for (var i = this.lines.length; i--;) {
        this.lines[i].setMap(null);
    }
    this.lines.length = 0;
}
};
