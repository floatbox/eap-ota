results.diagram = {
getSegments: function() {
    var that = this;
    var variants = results.vatiants;
    var samount = results. samount;
    var segments = [];
    for (var s = samount; s--;) {
        segments[i] = {
            items: [],
            dpt: 1440,
            arv: 0
        };
    }
    for (var i = 0, im = variants.length; i < im; i++) {
        var variant = variants[i];
        if (variant.improper) continue;
        if (variant.bars === undefined) {
            variant.bars = [];

        }
        for (var s = samount; s--;) {
            var bar = variant.bars[s];
            var segment = segments[s];
            segment.items.push(bar.el);
            segment.dpt = Math.min(segment.dpt, bar.dpt);
            segment.arv = Math.max(segment.arv, bar.arv);
        }
        
    }
}
};
