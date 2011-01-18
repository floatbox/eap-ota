search.map = {
init: function() {
    this.parent = search;
    if (typeof VEMap !== 'undefined') {
        this.obj = new VEMap('bingmap');
        this.defpoint = new VELatLong(55.751463, 37.621651);
        this.colors = [
            new VEColor(129, 170, 0, 0.9),
            new VEColor(196, 111, 38, 0.9),
            new VEColor(10, 160, 198, 0.9),
            new VEColor(196, 111, 38, 0.5)
        ];
        var f = search.segments[0].from.get(0).onclick();
        with (this.obj) {
            SetCredentials('AtNWTyXWDDDWemqtCdOBchagXymI0P5Sh14O7GSlQpl2BJxBm_xn6YRUR7TPhJD0');
            SetDashboardSize(VEDashboardSize.Tiny);
            LoadMap((f && f.lat && f.lng && new VELatLong(f.lat, f.lng)) || this.defpoint, 4);
            SetScaleBarDistanceUnit(VEDistanceUnit.Kilometers);
        }
        if (this.deferred) {
            this.show(this.deferred);
            delete(this.deferred);
        }
        this.active = true;
    }
},
show: function(segments) {
    this.obj.Clear();
    var lines = [], pins = [], pindex = {};
    for (var i = 0, im = segments.length; i < im; i++) {
        var f = segments[i].from, t = segments[i].to;
        var fp = f && f.lat && f.lng && new VELatLong(f.lat, f.lng);
        var tp = t && t.lat && t.lng && new VELatLong(t.lat, t.lng);
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
    if (this.parent.mode === 'rt' && lines.length === 2) {
        lines[1].color = this.colors[3];        
    }
    for (var i = 0, im = lines.length; i < im; i++) {
        var route = new VEShape(VEShapeType.Polyline, lines[i].points);
        route.SetLineWidth(3);
        route.SetLineColor(lines[i].color);
        route.HideIcon();
        this.obj.AddShape(route);
    }
    /*for (var i = 0, im = pins.length; i < im; i++) {
        this.map.AddShape(new VEShape(VEShapeType.Pushpin, pins[i]));
    }*/
    if (pins.length > 1) {
        this.obj.SetMapView(pins);
    } else {
        this.obj.SetCenterAndZoom(pins[0] || this.defpoint, 4);
    }
}
};
