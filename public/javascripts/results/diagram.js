results.diagram = {
init: function() {
    this.el = $('#offers-diagram');
    this.header = this.el.find('.odheader');
    this.content = this.el.find('.odcontent');
    this.width = 710;
    this.offset = 115;
    this.grid = [15, 30, 60, 90, 120, 180, 240, 360];
    var that = this;
    this.content.delegate('.segment', 'click', function() {
        var el = $(this);
        that.selectSegment(el.closest('.odpage').data('segment'), el.attr('data-flights'));
        that.savedSelected = that.selected.concat();
    });
    this.header.delegate('.odhsegment:not(.selected)', 'click', function() {
        var el = $(this);
        that.selected = that.savedSelected.concat();
        that.selectSegment(el.closest('td').data('segment'), undefined, false);
    });
},
update: function() {
    this.content.html('');
    this.minprice = 0;
    this.options = $.parseJSON($('#offers-options').attr('data-segments'));
    this.unselected = [];
    var template = '<div class="odhsegment"><h5>{from} — {to}</h5><h6>{date}</h6></div>';
    var row = this.header.find('.odhsegments tr').find('td').remove().end();
    for (var s = 0; s < results.samount; s++) {
        $('<div class="odpage"/>').data('segment', s).hide().appendTo(this.content);
        $('<td class="odhs' + (s + 1) + '"></td>').data('segment', s).html(template.supplant(this.options[s])).appendTo(row);
        this.unselected.push[s];
    }
    this.selected = [];
    this.savedSelected = [];
    this.selectVariants();
    this.showSegment(0);
},
selectVariants: function() {
    var variants = results.variants;
    if (variants[0].bars === undefined) {
        this.parseBars();
    }    
    var selected = this.selected;
    var proper = [];
    for (var i = 0, im = variants.length; i < im; i++) {
        var variant = variants[i];
        if (variant.improper) continue;
        var bars = variant.bars, improper = false;
        for (var b = bars.length; b--;) {
            if (selected[b] && selected[b] !== bars[b].flights) {
                improper = true;
                break;
            }
        }
        if (improper === false) {
            proper.push(variant);
        }
    }
    this.proper = proper;
},
showSegment: function(s) {
    var segment = this.getSegment(s);
    var list = this.content.find('.odpage').hide().eq(s).html('');
    var locations = $('<ul class="locations"><li>' + segment.dptcity + '</li></ul>').appendTo(list);
    if (segment.shift) {
        locations.append('<li>' + segment.arvcity + '</li>');
    }
    var bars = segment.bars;
    var length = segment.arv - segment.dpt;
    var that = this;
    for (var i = 0, im = bars.length; i < im; i++) {
        var item = bars[i].el.clone();
        item.find('.flight, .layover').each(function() {
            var el = $(this);
            var d = parseInt(el.attr('data-duration'), 10);
            el.width(Math.round(d / length * that.width) - 8);
        });
        var dpt = bars[i].dpt - segment.dpt;
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
        var gline = $('<div class="grid"/>'); 
        var gtime = '<li>' + this.formatTime(t) + '</li>';
        if (segment.shift) {
            gtime += '<li>' + this.formatTime(t + segment.shift) + '</li>';
        }
        gline.append('<ul class="times"><li>' + gtime + '</li></ul>');
        if (t === 1440) {
            gline.addClass('midnight');
        }
        gline.css('left', Math.round((t - segment.dpt) / length * this.width) + this.offset + 60);
        list.append(gline);
    }
    this.header.find('.selected').removeClass('selected');
    this.header.find('.odhsegment').eq(s).addClass('selected');
    list.show();
},
selectSegment: function(s, flights, auto) {
    this.selected[s] = flights;
    this.unselected = [];
    for (var i = 0; i < results.samount; i++) {
        if (this.selected[i] === undefined) {
            this.unselected.push(i);
        }
    }
    this.selectVariants();
    this.header.find('.selected').removeClass('selected');
    if (this.proper.length === 1 && auto !== false) {
        var variant = this.proper[0].el.clone();
        variant.removeClass('g-none').find('.variants').hide();
        this.content.addClass('latent');
        this.el.find('.offer').html('').append(variant).removeClass('latent');
    } else {
        this.el.find('.offer').addClass('latent');
        this.showSegment(auto === false ? s : this.unselected[0]);
        this.content.removeClass('latent');
    }
},
getSegment: function(s) {
    var that = this;
    var segment = {
        bars: [],
        contents: {},
        prices: {},
        dpt: 1440,
        arv: 0,
    };
    var variants = this.proper;
    var shifts = 0;
    for (var i = 0, im = variants.length; i < im; i++) {
        var variant = variants[i];
        var bar = variant.bars[s];
        var bf = bar.flights;
        if (segment.contents[bf] === undefined) {
            segment.bars.push(bar);
            segment.dpt = Math.min(segment.dpt, bar.dpt);
            segment.arv = Math.max(segment.arv, bar.arv);
            segment.contents[bf] = [i];
            segment.prices[bf] = [variant.offer.summary.price];
        } else {
            segment.contents[bf].push(i);
            segment.prices[bf].push(variant.offer.summary.price);
        }
        if (bar.shift !== segment.shift) {
            segment.shift = bar.shift;
            shifts++;
        }
    }
    if (shifts > 1) {
        segment.shift = 0;
    }
    segment.dptcity = this.options[s].from;
    segment.arvcity = this.options[s].to;
    return segment;
},
parseBars: function() {
    var variants = results.variants;
    for (var i = variants.length; i--;) {
        var v = variants[i];
        v.bars = [];
        v.el.find('.bars .segment').each(function(s) {
            var item = $(this);
            var options = $.parseJSON(item.attr('data-options'));
            v.bars[s] = {
                el: item,
                flights: item.attr('data-flights'),
                shift: options.shift,
                dpt: options.dpt,
                arv: options.arv
            };
        });
    }
},
formatTime: function(t) {
    return Math.floor((t % 1440) / 60) + ':' + (t % 60 / 100).toFixed(2).substring(2);
}
};
