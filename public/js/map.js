
//  Карта

app.Map = function(options) {

        this.options = $.extend({}, {
            map: {
                lon: 22,
                lat: 45
            }
        }, options || {});

        if (!options.el) return false;

        var init = ['dom', 'points', 'map', 'view', 'styles', 'events'];
        for (var i = 0; i < init.length; i++) this.init[init[i]](this);

        return this;
}

app.Map.prototype = {

    init: {
        dom: function(me) {
            me.dom = me.options.el;
            me.map = new YMaps.Map(me.dom);
        },

        map: function(me) {
            // центр карты из конфига
            me.map.setCenter(new YMaps.GeoPoint(me.options.map.lon, me.options.map.lat), 3);
            me.map.setMinZoom(1);
            // me.map.setType(YMaps.MapType.SATELLITE);

            // показываем метки
            me.places = me.showPlaces();
        },

        view: function(me) {
            // включаем клавиши +- и стрелки
            me.map.enableHotKeys();

            // колёсико мыши
            me.map.enableScrollZoom();

            // кнопки зума
            me.map.addControl(new YMaps.SmallZoom(), new YMaps.ControlPosition(YMaps.ControlPosition.TOP_LEFT, new YMaps.Point(1, 1)));

            // схема/спутник
            var type = new YMaps.TypeControl([YMaps.MapType.MAP, YMaps.MapType.SATELLITE])
            me.map.addControl(type, new YMaps.ControlPosition(YMaps.ControlPosition.BOTTOM_LEFT, new YMaps.Point(10, -5)));
        },

        points: function(me) {
            var ptp = app.Map.prototype;
            ptp.from = 'from';
            ptp.to = 'to';
            ptp.intermediate = 'intermediate';
            
            me.points = {};
        },

        styles: function(me) {
            var s = new YMaps.Style();
            s.lineStyle = new YMaps.LineStyle();
            s.lineStyle.strokeColor = 'e6489380';
            s.lineStyle.strokeWidth = '5';
            YMaps.Styles.add('#mapLine', s);
        },

        events: function(me) {
        }
    },

    // public
    setPoint: function(pos, loc, def) {
        var me = this;

        name = loc && loc.name;
        lon = loc && parseFloat(loc.lon);
        lat = loc && parseFloat(loc.lat);

        // переключаемся на схему
        def || me.map.setType(YMaps.MapType.MAP);

        // координаты неопределены, сбрасываем точку
        if (isNaN(lon) || isNaN(lat)) {
            me.points[pos] && me.map.removeOverlay(me.points[pos]);
            me.points[pos] = null;
            me.drawLine();
        } 
        else {
            var geo = new YMaps.GeoPoint(lon, lat); 

            // ставим новую точку
            if (!me.points[pos]) {
                me.points[pos] = new YMaps.Placemark(geo, {style: 'default#yellowSmallPoint', hasBalloon: false});
                me.map.addOverlay(me.points[pos]);
            }
            // точка уже есть, перемещаем её
            else {
                me.points[pos].setGeoPoint(geo);
            }
            
            me.points[pos].setIconContent(name);

            def || me.hidePlaces(); // дефолтная точка не стирает метки
            me.hideLine();

            def || me.map.panTo(geo, {
                flying: 1, 
                callback: function() {
                    me.map.setZoom(4);
                    window.setTimeout(function() {
                        me.drawLine();
                    }, 2000);
                }
            });
        }

        /*
        // определение координат
        if (name) {
            var gc = new YMaps.Geocoder(name, {results: 1});
            YMaps.Events.observe(gc, gc.Events.Load, function() {
                if (!this.length()) return;
                var p = me.points[type] = this.get(0);
                p.setStyle('default#airplaneIcon');
                me.map.addOverlay(p);
                me.map.panTo(p.getGeoPoint());
            });
        }
        */
    },

    // public
    clearPoints: function() {
        var me = this;
        me.setPoint(me.from);
        me.setPoint(me.to);
    },

    // private
    drawLine: function() {
        var me = this;

        me.hideLine();

        var s = me.points[me.from];
        var e = me.points[me.to];

        if (s && e) {
            var g = [s.getGeoPoint(), e.getGeoPoint()]

            me.line = new YMaps.Polyline(g);
            me.line.setStyle('#mapLine');

            me.map.addOverlay(me.line);

            me.map.setBounds(new YMaps.GeoCollectionBounds(g));
        };
    },

    // private
    hideLine: function() {
        var me = this;

        me.line && me.map.removeOverlay(me.line);
        me.line = null;
    },

    // public
    showPlaces: function() {
        var me = this;
        var pl = me.placesList;

        if (!pl) return;

        var places = new YMaps.ObjectManager();
        me.map.addOverlay(places);

        for (var l in pl) {
            var p = new YMaps.Placemark(new YMaps.GeoPoint(pl[l].ll[0], pl[l].ll[1]), {style: 'default#pinkSmallPoint', hasBalloon: false});
            p.url = Routes.geo_flight_query(pl[l].name);

            p.setIconContent(pl[l].name + '<br>от ' +  Ext.util.Format.RuR(pl[l].price));

            YMaps.Events.observe(p, p.Events.Click, function(p, el) {

                search.load.get.url = p.url;
                search.form.load(search.load.get);

                me.map.panTo(p.getGeoPoint(), {
                    flying: 1, 
                    callback: function() {
                        me.map.setZoom(4);
                    }
                });
            });

            places.add(p, pl[l].mm[0], pl[l].mm[1]);
        }

        return places;
    },

    // public
    hidePlaces: function(pl) {
        if (this.places) this.places.removeAll();
    },

    set: function() {
    },

    reset: function() {
        var me = this;
        me.clearPoints();
        me.init.map(me);
    }
};

