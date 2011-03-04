results.diagram = {
getSegments: function() {
    var that = this;
    var variants = results.variants;
    var samount = results. samount;
    var segments = [];
    for (var s = samount; s--;) {
        segments[s] = {
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
            segment.items.push(bar.el);
            segment.dpt = Math.min(segment.dpt, bar.dpt);
            segment.arv = Math.max(segment.arv, bar.arv);
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
            dpt: item.attr('data-dpt'),
            arv: item.attr('data-arv')                    
        };
    }
    return bars;
},
update: function() {
    var segments = this.getSegments();
    var list = $('<div/>');
    var items = segments[0].items;
    for (var i = 0, im = items.length; i < im; i++) {
        list.append(items[i]);
    }
    $('#offers-diagram').html(list.html());
}
};
