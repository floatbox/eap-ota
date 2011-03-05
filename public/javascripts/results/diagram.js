results.diagram = {
getSegments: function() {
    var that = this;
    var variants = results.variants;
    var samount = results. samount;
    var segments = [];
    for (var s = samount; s--;) {
        segments[s] = {
            contents: {},
            items: [],
            dpt: 1440,
            arv: 0
        };
    }
    for (var i = 0, im = variants.length; i < im; i++) {
        var variant = variants[i];
        if (variant.improper) continue;
        if (variant.bars === undefined) {
            variant.bars = this.parseBars(variant.el.find('.bars .segment'));
        }
        for (var s = samount; s--;) {
            var bar = variant.bars[s];
            var segment = segments[s];
            if (segment.contents[bar.flights] === undefined) {            
                segment.items.push(bar.el);
                segment.dpt = Math.min(segment.dpt, bar.dpt);
                segment.arv = Math.max(segment.arv, bar.arv);
                segment.contents[bar.flights] = true;
            }
        }
    }
    return segments;
},
parseBars: function(items) {
    var bars = [];
    for (var i = items.length; i--;) {
        var item = items.eq(i);
        bars[i] = {
            el: item,
            flights: item.attr('data-flights'),
            dpt: item.attr('data-dpt'),
            arv: item.attr('data-arv')                    
        };
    }
    return bars;
},
update: function() {
    var segments = this.getSegments();
    var dwidth = 750;
    var container = $('#offers-diagram').html('');
    for (var s = 0; s < segments.length; s++) {
        var list = $('<div/>');    
        var segment = segments[s];
        var items = segment.items;        
        var length = segment.arv - segment.dpt;
        for (var i = 0, im = items.length; i < im; i++) {
            var item = items[i].clone();
            item.find('.flight, .layover').each(function() {
                var el = $(this);
                var d = parseInt(el.attr('data-duration'), 10);
                el.width(Math.round(d / length * dwidth) - 8);
            });
            var dpt = parseInt(item.attr('data-dpt'), 10) - segment.dpt;
            item.find('.bar').css('left', Math.round(dpt / length * dwidth) + 80);
            list.append(item);
        }
        container.append(list);
        if (s > 0) list.hide();
    }
    $('#offers-diagram').append(list);
}
};
