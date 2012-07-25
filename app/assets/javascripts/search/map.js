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
    this.prices = this.el.find('.smap-prices');
    this.prices.click(function() {
        if (!that.prices.hasClass('smp-pressed')) that.loadPrices();
    });
    this.colors = ['#81aa00', '#db7100', '#0aa0c6', '#bf00db', '#db0048', '#9a5000'];
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
        this.prices.toggleClass('smp-hidden', !zoomVisible);
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
            zoomControlOptions: {
                style: google.maps.ZoomControlStyle.SMALL
            },
            scrollwheel: false,
            minZoom: 2,
            maxZoom: 8
        });
        this.bounds = this.defpoint;
        if (this.deferred) {
            this.showSegments(this.deferred);
            delete this.deferred;
        }
        this.load = $.noop;
        this.toggleZoom(this.content.height());
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
showSegments: function(segments) {
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
    this.updatePrices(segments);
    var bounds = new google.maps.LatLngBounds();
    for (var i = 0, im = points.length; i < im; i++) {
        var point = points[i];
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
    } else if (points[0]) {
        this.bounds = points[0].latlng || this.defpoint;
    } else {
        this.bounds = this.defpoint;
    }
    this.fitBounds();
    this.cachedSegments = segments;
    this.pricesMode = false;
},
updatePrices: function(segments, stealth) {
    if (segments[0] && segments[0].dpt && search.mode.selected !== 'mw') {
        var sd = search.dates;
        var dates = sd.monthes[sd.position].ptitle + '—' + sd.monthes[sd.position + 1].ptitle;
        this.prices.html(local.search.prices.absorb(segments[0].dpt.from.nowrap(), dates));
        this.prices.attr('data-from', segments[0].dpt.iata);
        this.prices.attr('data-date', sd.monthes[sd.position].el.find('.first').attr('data-dmy'));
        if (!stealth) {
            this.prices.removeClass('smp-pressed').show();
        }
    } else {
        this.prices.hide();
    }
},
loadPrices: function() {
    var that = this;
    this.prices.addClass('smp-pressed');
    $.get('/price_map', {
        from: this.prices.attr('data-from'),
        date: this.prices.attr('data-date'),
        rt: search.mode.selected === 'rt' ? 1 : 0
    }, function(data) {
        that.showPrices(data);
    });
},
showPrices: function(items) {
    var that = this;
    this.prices.hide();
    this.clean();
    if (!items || items.length === 0) return;
    var template = '<p class="sml-city">{0}</p><p class="sml-price">{1}&nbsp;<span class="ruble">Р</span></p><p class="sml-dates">{2}</p>';
    var bounds = new google.maps.LatLngBounds();    
    for (var i = 0, im = items.length; i < im; i++) {
        var item = items[i];
        var dates = [item.date1.substring(8, 10) + '.' + item.date1.substring(5, 7)];
        var indexes = [search.dates.dmyIndex[item.date1.substring(8, 10) + item.date1.substring(5, 7) + item.date1.substring(2, 4)]];
        if (item.date2) {
            dates[1] = item.date2.substring(8, 10) + '.' + item.date2.substring(5, 7);
            indexes[1] = search.dates.dmyIndex[item.date2.substring(8, 10) + item.date2.substring(5, 7) + item.date2.substring(2, 4)];
        }
        var content = template.absorb(item.to.name_ru, Math.round(item.price).separate(), dates.join('—'));
        var latlng = new google.maps.LatLng(item.to.lat, item.to.lng);
        var label = new mapLabel({
            position: latlng,
            title: content,
            map: this.api
        });
        label.$el.addClass('sml-active');
        label.$el.data('city', {name: item.to.name_ru, iata: item.to.iata, type: 'city'});
        label.$el.data('dates', indexes);
        label.$el.click(function() {
            that.applyPrice($(this));
        });
        bounds.extend(latlng);
        this.items.push(label);
    }
    if (items.length > 1 && !this.pricesMode) {
        this.bounds = bounds;    
        this.fitBounds();
    }
    this.pricesMode = true;
},
applyPrice: function(el) {
    search.locations.segments[0].arv.set(el.data('city'));
    search.dates.setSelected(el.data('dates'));
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
    this.$el = $('<div class="smap-label"></div>');
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