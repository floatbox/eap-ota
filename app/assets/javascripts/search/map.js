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
    this.prices.init(this.el.find('.smap-prices'));
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
        this.prices.el.toggleClass('smp-hidden', !zoomVisible);
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
        that.control.html(lang.mapControl.collapse);
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
        that.control.html(lang.mapControl.expand);
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
        this.prices.update({
            title: lang.priceMap.link.absorb(segments[0].dpt.from.nowrap(), dates),
            from: segments[0].dpt.iata,
            date: sd.monthes[sd.position].el.find('.first').attr('data-dmy')
        });
        if (!stealth) {
            this.prices.show();
        }
    } else {
        this.prices.hide();
    }
},
loadPrices: function() {
    var that = this;
    $.ajax({
        url: '/price_map',
        data: {
            from: this.prices.el.attr('data-from'),
            date: this.prices.el.attr('data-date'),
            rt: search.mode.selected === 'rt' ? 1 : 0
        },
        success: function(data) {
            that.showPrices(data || []);
        },
        error: function() {
            that.showPrices([]);
        },
        timeout: 45000
    });
},
showPrices: function(items) {
    var that = this;
    this.clean();
    if (items.length === 0) {
        this.prices.el.removeClass('smp-pressed');
        this.prices.el.addClass('smp-failed');
        this.pricesMode = true;
        this.prices.clicked = false;
        return;
    }
    var template = '<p class="sml-city">{0}</p><p class="sml-price">{1}&nbsp;<span class="ruble">Р</span></p><p class="sml-dates">{2}</p>';
    var bounds = new google.maps.LatLngBounds();
    var pmin = items[0].price, pmax = items[0].price;
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
        label.price = item.price;
        label.$el.addClass('sml-active');
        label.$el.data('city', {name: item.to.name_ru, iata: item.to.iata, type: 'city'});
        label.$el.data('dates', indexes);
        label.$el.click(function() {
            that.applyPrice($(this));
        });
        bounds.extend(latlng);
        if (item.price < pmin) pmin = item.price;
        if (item.price > pmax) pmax = item.price;
        this.items.push(label);
    }
    if (items.length > 1 && !this.pricesMode) {
        this.bounds = bounds;
        this.fitBounds();
    }
    if (items.length > 1 && pmin / pmax < 0.95) {
        this.prices.show();
        this.prices.process(pmin, pmax);
    } else {
        this.prices.hide();
    }
    if (this.prices.clicked && !search.dates.el.hasClass('sd-hidden')) {
        this.slideDown();
    }
    this.prices.clicked = false;
    this.pricesMode = true;
},
filterPrices: function(limit) {
    var bounds = new google.maps.LatLngBounds();
    for (var i = this.items.length; i--;) {
        var item = this.items[i];
        if (item.price > limit) {
            item.$el.hide();
        } else {
            bounds.extend(item.position);
            item.$el.show();
        }
    }
    this.bounds = bounds;
    this.fitBounds();
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

/* Prices control */
search.map.prices = {
init: function(context) {
    var that = this;
    this.el = context;
    this.link = this.el.find('.smp-link');
    this.link.click(function() {
        that.clicked = true;
        that.el.removeClass('smp-failed');
        that.el.addClass('smp-pressed');
        search.map.loadPrices();
    });
    this.empty = this.el.find('.smp-empty');
    this.loading = this.el.find('.smp-loading');
    this.slider = this.el.find('.smp-slider');
    this.slider.find('.smps-base').on('click', function(event) {
        var offset = event.pageX - $(this).offset().left - 3;
        that.apply(that.offset = offset.constrain(0, that.width), true);
    });
    this.selected = this.slider.find('.smps-selected');
    this.control = this.slider.find('.smps-control');
    this.control.mousedown(function(event) {
        that.drag(event);
    });
    this.$move = function(event) {
        that.move(event.pageX);
    };
    this.$drop = function(event) {
        that.drop();
    };
    this.value = this.slider.find('.smps-value');
},
update: function(options) {
    this.slider.hide();
    this.link.html(options.title).show();
    this.el.removeClass('smp-failed');
    this.el.attr('data-from', options.from);
    this.el.attr('data-date', options.date);
},
process: function(min, max) {
    this.el.removeClass('smp-failed');
    this.el.removeClass('smp-pressed');
    this.link.hide();
    this.slider.show();
    this.values = {
        min: min,
        max: max,
        range: max - min
    };
    this.width = this.slider.find('.smps-base').width() - 7;
    this.scales = [100, 100, 500, 1000];
    this.offset = this.width;
    this.apply(this.offset);
},
apply: function(offset, filter) {
    var limit = Math.ceil(this.values.max);
    if (offset < this.width) {
        var factor = offset / this.width;
        var exact = this.values.min + Math.pow(factor, 2) * this.values.range;
        var scale = this.scales[Math.floor(factor * this.scales.length)];
        limit = Math.min(limit, Math.ceil(exact / scale) * scale);
    }
    this.control.css('left', offset);
    this.selected.css('width', offset);
    this.value.html(lang.priceMap.limit.absorb(limit.separate()));
    if (filter) {
        search.map.filterPrices(limit);
    }
},
drag: function(event) {
    this.dragging = {
        offset: this.offset,
        x: event.pageX
    };
    $(document).on('mousemove', this.$move);
    $(document).on('mouseup', this.$drop);
    event.stopPropagation();
    event.preventDefault();
},
move: function(x) {
    var d = this.dragging;
    var dx = Math.round(x - d.x);
    if (dx !== d.dx) {
        var pos = this.offset + dx;
        d.offset = pos.constrain(0, this.width);
        d.dx = dx;
        this.apply(d.offset);
    }
},
drop: function() {
    $(document).off('mousemove', this.$move);
    $(document).off('mouseup', this.$drop);
    if (this.dragging) {
        this.apply(this.offset = this.dragging.offset, true);
        delete this.dragging;
    }
},
show: function() {
    this.el.show();
},
hide: function() {
    this.el.hide();
}
};
