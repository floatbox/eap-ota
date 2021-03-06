/* Map */
search.map = {
init: function() {
    this.el = $('#search-map');
    this.content = this.el.find('.smap-content');
    this.content.css('top', -Math.round(this.margin / 2));
    this.wrapper = $('#search-wrapper');
    if (!browser.ios) {
        this.bindResize();
    }
    var that = this;
    this.prices.init(this.el.find('.smap-prices'));
    this.colors = ['#81aa00', '#db7100', '#0aa0c6', '#bf00db', '#db0048', '#9a5000'];
    this.items = [];

    var applyState = function(event) {
        if (event.state && event.state.pricesMap) {
            that.showPrices(event.state.pricesMap, true);
        }
        if (event.state && event.state.selectedPriceCity) {
            search.locations.segments[0].arv.set(event.state.selectedPriceCity);
            search.dates.setSelected(event.state.selectedPriceDates);
        }
    };
    if (window.addEventListener) {
        window.addEventListener('popstate', applyState, false);
    }
},
bindResize: function() {
    var that = this;
    $w.bind('resize', function() {
        if (that.el.is(':visible')) that.resize();
    });
},
resize: function(instant) {
    var dh = 62; // Page header
    dh += search.locations.el.height();
    dh += search.dates.el.height() + 2;
    dh += search.options.el.height();
    dh += results.header.height;
    var height = $w.height() - dh;
    if (height < 150) {
        this.el.addClass('sm-hidden');
        this.content.height(26);
    } else {
        this.el.removeClass('sm-hidden');
        this.content.height(height);
        this.toggleZoom(height);
    }
    if (this.api && this.bounds) {
        this.fitBounds();
    }
},
toggleZoom: function(h) {
    var zoomVisible = h > 105;
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
            zoomControlOptions: {
                style: google.maps.ZoomControlStyle.SMALL,
                position: google.maps.ControlPosition.LEFT_TOP
            },
            scrollwheel: false,
            minZoom: 2,
            maxZoom: 8
        });
        var zoomOffset = document.createElement('div');
        zoomOffset.style.height = '36px';
        this.api.controls[google.maps.ControlPosition.TOP_LEFT].push(zoomOffset);
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
    this.el.removeClass('sm-hidden');
    this.content.animate({
        height: Math.max(36, ch + dh)
    }, 300, function() {
        search.dates.toggleHidden(true);
        google.maps.event.trigger(that.api, 'resize');
        that.wrapper.height('').css('overflow', '');
        that.resize();
    });
    search.dates.el.find('.sdt-tab').delay(150).fadeOut(150);
},
slideUp: function() {
    var that = this;
    var wh = this.wrapper.height();
    this.wrapper.height(wh).css('overflow', 'hidden');
    search.dates.toggleHidden(false);
    var ch = search.dates.el.height();
    this.toggleZoom(wh - ch);
    this.content.animate({
        height: Math.max(36, wh - ch)
    }, 300, function() {
        google.maps.event.trigger(that.api, 'resize');
        that.wrapper.height('').css('overflow', '');
        if (that.prices.el.find('.smp-collapse').length) {
            that.prices.showExpand();
        }
        that.resize();
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
updatePrices: function(segments) {
    if (segments[0] && segments[0].dpt && !segments[0].arv && search.mode.selected !== 'mw') {
        var sd = search.dates;
        var dates = sd.monthes[sd.position].ptitle + ' — ' + sd.monthes[sd.position + 1].ptitle;
        this.prices.update({
            title: I18n.t('search.map.link', {from: segments[0].dpt.from.nowrap(), dates: dates}),
            from: segments[0].dpt.iata,
            date: sd.monthes[sd.position].el.find('.first').attr('data-dmy')
        });
        if (this.pricesMode && search.dates.el.hasClass('sd-hidden')) {
            this.loadPrices();
        }
    } else {
        this.prices.slider.hide();
        this.prices[search.dates.el.hasClass('sd-hidden') ? 'showCollapse' : 'showExpand']();
    }
},
loadPrices: function() {
    var that = this;
    this.prices.slider.hide();
    this.prices.showLoading();
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
showPrices: function(items, fromState) {
    var that = this;
    this.clean();
    if (items.length === 0) {
        this.prices.link.html('<div class="smpl-content">' + I18n.t('search.map.empty') + '</div>');
        return;
    }
    var template = '<a class="sml-link" href="#{3}"><span class="sml-city">{0}</span><span class="sml-price">{1}&nbsp;<span class="ruble">Р</span></span><span class="sml-dates">{2}</span></a>';
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
        var content = template.absorb(item.to.name_ru, Math.round(item.price).separate(), dates.join('—'), item.code);
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
        label.$el.click(function(event) {
            if (!(event.metaKey || event.ctrlKey || event.altKey)) {
                that.applyPrice($(this));
            }
        });
        label.$el.find('.sml-link').click(function(event) {
            if (!(event.metaKey || event.ctrlKey || event.altKey)) {
                event.preventDefault();
            }
        });
        bounds.extend(latlng);
        if (item.price < pmin) pmin = item.price;
        if (item.price > pmax) pmax = item.price;
        this.items.push(label);
    }
    this.pricesOrigin = new google.maps.LatLng(items[0].from.lat, items[0].from.lng);
    bounds.extend(this.pricesOrigin);
    this.bounds = bounds;
    if (!this.pricesMode) {
        this.fitBounds();
    }
    if (this.prices.el.find('.smp-progress').length && !search.dates.el.hasClass('sd-hidden')) {
        setTimeout(function() {
            that.slideDown();
        }, 100);
    }
    if (items.length > 1 && pmin / pmax < 0.95) {
        this.prices.process(pmin, pmax);
    } else {
        this.prices.link.html('<div class="smpl-content smp-simple">' + I18n.t('search.map.title', {min: Math.floor(pmin).separate()}) + '&nbsp;<span class=\"ruble\">Р</span></div>');
    }
    if (!fromState && window.history.pushState) {
        window.history.pushState({pricesMap: items}, document.title);
    }
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
    bounds.extend(this.pricesOrigin);
    this.bounds = bounds;
    this.fitBounds();
},
applyPrice: function(el) {
    search.locations.segments[0].arv.set(el.data('city'));
    search.dates.setSelected(el.data('dates'));
    if (window.history.pushState) {
        window.history.pushState({
            selectedPriceCity: el.data('city'),
            selectedPriceDates: el.data('dates')
        }, document.title);
    }
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
    this.link.on('click', '.smp-load', function() {
        search.map.loadPrices();
    });
    this.link.on('click', '.smp-expand', function() {
        that.showCollapse();
        search.map.slideDown();
    });
    this.link.on('click', '.smp-collapse', function() {
        search.map.slideUp();
    });
    this.showExpand();
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
    this.height = this.el.outerHeight();
},
showExpand: function() {
    this.link.html('<div class="smpl-content smp-expand">' + I18n.t('search.map.expand') + '</div>').show();
},
showCollapse: function() {
    this.link.html('<div class="smpl-content smp-collapse">' + I18n.t('search.map.collapse') + '</div>').show();
},
showLoading: function() {
    this.link.html('<div class="smpl-content"><span class="smp-progress">' + I18n.t('search.map.loading') + '</span></div>').show();
},
update: function(options) {
    this.slider.hide();
    this.link.html('<div class="smpl-content smp-load">' + options.title + '</div>').show();
    this.el.attr('data-from', options.from);
    this.el.attr('data-date', options.date);
},
process: function(min, max) {
    this.link.hide();
    this.slider.show();
    this.values = {
        min: min,
        max: max,
        range: max - min
    };
    this.slider.find('.smps-title').html(I18n.t('search.map.title', {min: Math.floor(min).separate()}));
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
    this.value.html(I18n.t('search.map.limit', {max: limit.separate()}));
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
}
};
