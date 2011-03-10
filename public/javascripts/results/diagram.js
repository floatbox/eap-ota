results.diagram = {
init: function() {
    this.el = $('#offers-diagram');
    this.width = 750;
    this.offset = 80;
    this.grid = [15, 30, 60, 90, 120, 180, 240, 360];
    var that = this;
    this.el.delegate('.segment', 'click', function() {
        var index = that.segments[0].contents[$(this).attr('data-flights')];
        //console.log(index);
    });
},
getSegment: function(s, flights) {
    var that = this;
    var variants = results.variants;
    var segment = {
        items: [],
        contents: {},
        dpt: 1440,
        arv: 0
    };
    if (variants[0].bars === undefined) {
        this.parseBars();
    }
    var all = flights === undefined;
    for (var i = 0, im = variants.length; i < im; i++) {
        var variant = variants[i];
        var bar = variant.bars[s];
        if (!variant.improper && (all || flights[bar.flights] !== undefined)) {
            if (segment.contents[bar.flights] === undefined) {            
                segment.items.push(bar.el);
                segment.dpt = Math.min(segment.dpt, bar.dpt);
                segment.arv = Math.max(segment.arv, bar.arv);
                segment.contents[bar.flights] = [i];
            } else {
                segment.contents[bar.flights].push(i);
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
    this.el.hide().html('');
    this.segments = [];
    var samount = results.samount;
    for (var s = 0; s < results.samount; s++) {
        var segment = this.getSegment(s);    
        var list = $('<div class="odpage"/>');
        this.updateList(list, segment);
        this.el.append(list.toggle(s === 0));
        this.segments[s] = segment;
    }
    this.el.show();
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
        item.find('.bar').css('left', Math.round(dpt / length * this.width) + this.offset);
        list.append(item);
    }
    for (var i = this.grid.length; i--;) {
        if (length / this.grid[i] > 8) break;
        var gstep = this.grid[i];
    }
    var tmin = Math.ceil(segment.dpt / gstep) * gstep;
    var tmax = Math.floor(segment.arv / gstep) * gstep;
    console.log(segment.arv, tmax);
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
