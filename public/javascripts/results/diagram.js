results.diagram = {
init: function() {
    this.el = $('#offers-diagram');
    this.content = this.el.find('.odcontent');
    this.width = 730;
    this.offset = 115;
    this.grid = [15, 30, 60, 90, 120, 180, 240, 360];
    var that = this;
    this.el.delegate('.segment', 'click', function() {
        var el = $(this);
        that.selectSegment(el.closest('.odpage').data('segment'), el.attr('data-flights'));
    });
},
selectSegment: function(s, flights) {
    this.selected[s] = flights;
    var index = this.segments[s].contents[flights];
    var properFlights = [];
    var properVariants = [];
    this.unselected = [];
    for (var s = 0; s < results.samount; s++) {
        properFlights[s] = {};
        if (this.selected[s] === undefined) {
            this.unselected.push(s);
        }
    }
    for (var i = 0, im = index.length; i < im; i++) {
        var bars = results.variants[index[i]].bars;
        var improper = false;
        for (var b = bars.length; b--;) {
            if (this.selected[b] && this.selected[b] !== bars[b].flights) {
                improper = true;
                break;
            }
        }
        if (improper === false) {
            properVariants.push(index[i]);
            for (var b = bars.length; b--;) {
                properFlights[b][bars[b].flights] = true;
            }
        }
    }
    var lists = this.content.find('.odpage').hide();
    if (properVariants.length === 1) {
        var variant = results.variants[properVariants[0]].el.clone();
        variant.removeClass('g-none').find('.variants').hide();
        this.el.find('.offer').html('').append(variant).removeClass('latent');
    } else {
        var s = this.unselected[0];
        var segment = this.getSegment(s, properFlights[s]);
        this.minprice = Math.max(this.minprice, results.variants[properVariants[0]].offer.summary.price);
        this.updateList(lists.eq(s).html(''), segment);
        lists.eq(s).show();
    }
},
getSegment: function(s, flights) {
    var that = this;
    var variants = results.variants;
    var segment = {
        items: [],
        contents: {},
        prices: {},
        dpt: 1440,
        arv: 0,
    };
    if (variants[0].bars === undefined) {
        this.parseBars();
    }
    var all = flights === undefined;
    for (var i = 0, im = variants.length; i < im; i++) {
        var variant = variants[i];
        var bar = variant.bars[s];
        var bf = bar.flights;
        if (!variant.improper && (all || flights[bf] !== undefined)) {
            if (segment.contents[bf] === undefined) {
                segment.items.push(bar.el);
                segment.dpt = Math.min(segment.dpt, bar.dpt);
                segment.arv = Math.max(segment.arv, bar.arv);
                segment.contents[bf] = [i];
                segment.prices[bf] = [variant.offer.summary.price];
            } else {
                segment.contents[bf].push(i);
                segment.prices[bf].push(variant.offer.summary.price);
            }        
        }
    }
    return segment;
},
parseBars: function() {
    var variants = results.variants;
    for (var i = variants.length; i--;) {
        var v = variants[i];
        v.bars = [];
        v.el.find('.bars .segment').each(function(s) {
            var item = $(this);
            v.bars[s] = {
                el: item,
                flights: item.attr('data-flights'),
                dpt: item.attr('data-dpt'),
                arv: item.attr('data-arv')
            };
        });
    }
},
update: function() {
    this.content.hide().html('');
    this.segments = [];
    this.minprice = 0;
    this.unselected = [];
    var samount = results.samount;
    for (var s = 0; s < results.samount; s++) {
        var segment = this.getSegment(s);    
        var list = $('<div class="odpage"/>').data('segment', s);
        this.updateList(list, segment);
        this.content.append(list.toggle(s === 0));
        this.segments[s] = segment;
    }
    this.content.show();
    this.selected = [];
},
updateList: function(list, segment) {
    var that = this;
    var items = segment.items;
    var length = segment.arv - segment.dpt;
    for (var i = 0, im = items.length; i < im; i++) {
        var item = items[i].clone();
        item.find('.flight, .layover').each(function() {
            var el = $(this);
            var d = parseInt(el.attr('data-duration'), 10);
            el.width(Math.round(d / length * that.width) - 8);
        });
        var dpt = parseInt(item.attr('data-dpt'), 10) - segment.dpt;
        var prices = $.grep(segment.prices[item.attr('data-flights')].unique(), function(p) {
            return p >= that.minprice;
        });
        if (this.unselected.length === 1) {
            prices.length = 1;
        }
        item.find('.a-button').html((prices.length > 1 ? 'От ' : '') + Math.round(prices[0]) + ' Р');
        item.find('.bar').css('left', Math.round(dpt / length * this.width) + this.offset);
        list.append(item);
    }
    for (var i = this.grid.length; i--;) {
        if (length / this.grid[i] > 8) break;
        var gstep = this.grid[i];
    }
    var tmin = Math.ceil(segment.dpt / gstep) * gstep;
    var tmax = Math.floor(segment.arv / gstep) * gstep;
    for (var t = tmin; t < tmax + 1; t += gstep) {
        var time = $('<div class="grid"/>');
        time.html('<span class="time">' + Math.floor((t % 1440) / 60) + ':' + (t % 60 / 100).toFixed(2).substring(2) + '</span>');
        if (t === 1440) {
            time.addClass('midnight');
        }
        time.css('left', Math.round((t - segment.dpt) / length * this.width) + this.offset + 65);
        list.append(time);
    }
}
};
