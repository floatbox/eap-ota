results.diagram = {
init: function() {
    this.el = $('#offers-diagram');
    this.header = this.el.find('.odheader');
    this.content = this.el.find('.odcontent');
    this.width = 710;
    this.offset = 115;
    this.grid = [15, 30, 60, 90, 120, 180, 240, 360, 480, 720, 1440];
    var that = this;
    this.content.delegate('.segment', 'click', function(event) {
        event.preventDefault();
        var el = $(this);
        var s = el.closest('.odsegment').data('segment');
        if (el.parent().hasClass('ods-improper')) {
            that.selected = [];
        }
        that.selectSegment(s, el.attr('data-flights'));
    });
    this.content.delegate('.sort-items .link:not(.sortedby)', 'click', function() {
        that.sortby = $(this).attr('data-sort');
        that.sortSegments();
        that.updateSegments();
    });
    this.header.delegate('.odhsegment:not(.selected)', 'click', function() {
        that.showSegment($(this).closest('td').data('segment'));
    });
},
update: function(reset) {
    var variants = results.variants;
    if (variants[0].bars === undefined) {
        this.parseBars();
    }
    this.variants = [];
    for (var i = 0, im = variants.length; i < im; i++) {
        var variant = variants[i];
        if (variant.improper !== true) {
            this.variants.push(variant);
        }
    }
    if (reset) {
        this.sortby = 'price';
    }
    this.content.height(this.content.height()).html('');
    if (this.variants.length !== 0) {
        this.options = $.parseJSON($('#offers-options').attr('data-segments'));
        this.segments = [];
        var template = '<div class="odhsegment"><h5>{from} — {to}</h5><h6>{date}</h6></div>';
        var row = this.header.find('.odhsegments tr').find('td').remove().end();
        for (var s = 0; s < results.samount; s++) {
            this.segments[s] = this.getSegment(s);
            this.segments[s].el = $('<div class="odsegment"/>').data('segment', s).hide().appendTo(this.content);
            $('<td class="odhs' + (s + 1) + '"></td>').data('segment', s).html(template.supplant(this.options[s])).appendTo(row);
            this.drawSegment(s);
        }
        if (this.segments.length > 1) {
            $('<td class="odh-tip">Обратите внимание, что не все варианты перелёта <span class="odh-direction1">туда</span> совместимы с&nbsp;любым вариантом перелёта <span class="odh-direction2">обратно</span>.</td>').appendTo(row);
        }
        this.selected = [];
        this.header.show();
        if (this.sortby !== 'price') {
            this.sortSegments();
        }
        this.updateSegments();
        this.showSegment(0);
        this.content.height('auto');
    } else {
        this.header.hide();
        this.content.append($('#offers-pcollection').prev().clone()).height('auto');
        this.el.find('.offer').addClass('latent');
    }
},
showVariant: function() {
    var variant;
    var variants = this.variants;
    var selected = this.selected;
    for (var i = 0, im = variants.length; i < im; i++) {
        var v = variants[i], bars = v.bars, improper = false;
        for (var b = bars.length; b--;) {
            if (selected[b] !== bars[b].flights) {
                improper = true;
                break;
            }
        }
        if (improper === false) {
            variant = v.el.clone();
            break;
        }
    }
    variant.removeClass('g-none').find('.variants').hide();
    this.content.addClass('latent');
    this.header.find('.selected').removeClass('selected');
    this.el.find('.offer').html('').append(variant).removeClass('latent prebooking');
},
showSegment: function(s) {
    this.el.find('.offer').addClass('latent');
    this.header.find('.selected').removeClass('selected');
    this.header.find('.odhsegment').eq(s).addClass('selected');
    this.content.find('.odsegment').hide();
    this.content.removeClass('latent');
    this.segments[s].el.show();
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
    var variants = this.variants;
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
            segment.prices[bf] = [Math.round(variant.offer.summary.price)];
        } else {
            segment.contents[bf].push(i);
            segment.prices[bf].push(Math.round(variant.offer.summary.price));
        }
        if (bar.shift !== segment.shift) {
            segment.shift = bar.shift;
            shifts++;
        }
    }
    segment.order = [];
    for (var i = 0, im = segment.bars.length; i < im; i++) {
        var bar = segment.bars[i];
        segment.order.push({
            n: i,
            price: segment.prices[bar.flights][0],
            duration: bar.arv - bar.dpt,
            departure: bar.dpt,
            carrier: bar.carrier
        });
    }
    if (shifts > 1) {
        segment.shift = 0;
    }
    segment.dptcity = this.options[s].from;
    segment.arvcity = this.options[s].to;
    return segment;
},
drawSegment: function(s) {
    var segment = this.segments[s], stitle;
    segment.el.html('<div class="ods-title"><h4>Все варианты</h4></div>');
    segment.el.append($('#offers-all .offers-sort .sort-items').clone());
    segment.title = segment.el.find('.ods-title h4');
    var list = $('<div class="ods-content"></div>').appendTo(segment.el);
    var locations = $('<ul class="locations"><li>' + segment.dptcity + '</li></ul>').appendTo(list);
    if (segment.shift) {
        locations.append('<li>' + segment.arvcity + '</li>');
    }
    var bars = segment.bars;
    var length = segment.arv - segment.dpt;
    var that = this;
    for (var i = 0, im = bars.length; i < im; i++) {
        var item = bars[i].el;
        var dpt = bars[i].dpt - segment.dpt;
        item.find('.flight, .layover').each(function() {
            var el = $(this);
            var d = parseInt(el.attr('data-duration'), 10);
            el.width(Math.round(d / length * that.width) - 8);
        });
        var left = Math.round(dpt / length * this.width);
        item.find('.bar').css({
            left: left + this.offset,
            width: this.width + 140 - left
        });
        var prices = segment.prices[bars[i].flights];
        if (prices.length > 1) {
            prices = prices.unique();
            if (prices.length > 1) {
                item.find('.a-button').html('от ' + prices[0] + '&nbsp;р.');
            }
        }
    }
    list.append('<div class="ods-proper"></div>');
    list.append('<div class="ods-improper"><div class="ods-title"><h4>Остальные варианты</h4><p>Выбор этих вариантов сбросит другие выбранные перелёты.</p></div></div>');
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
},
properFlights: function(s) {
    var variants = this.variants;
    var selected = [];
    for (var i = results.samount; i--;) {
        selected[i] = (s !== i) ? this.selected[i] : undefined;
    }
    var proper = {};
    for (var i = variants.length; i--;) {
        var variant = variants[i];
        var bars = variant.bars, improper = false;
        for (var b = bars.length; b--;) {
            if (selected[b] && selected[b] !== bars[b].flights) {
                improper = true;
                break;
            }
        }
        if (improper === false) {
            proper[bars[s].flights] = true;
        }
    }
    return proper;
},
selectSegment: function(s, flights) {
    var unselected, autoselect = false;
    this.selected[s] = flights;
    this.updateSegments();
    for (var i = this.segments.length; i--;) {
        if (this.selected[i] === undefined) {
            var pflights = this.segments[i].el.find('.ods-proper > .segment');
            if (pflights.length === 1) {
                this.selected[i] = pflights.eq(0).attr('data-flights');
                autoselect = true;
            } else {
                unselected = i;
            }
        }
    }
    if (autoselect) {
        this.updateSegments();
    }
    if (unselected !== undefined) {
        this.showSegment(unselected);
    } else {
        this.showVariant();
    }
    var st = $('#offers').offset().top - results.header.height();
    if ($(window).scrollTop() > st) {
        $.animateScrollTop(st);
    }
},
updateSegments: function() {
    var that = this;
    for (var s = this.segments.length; s--;) {
        var segment = this.segments[s];
        var pf = this.properFlights(s);
        var sf = this.selected[s];
        segment.el.find('.selected').removeClass('selected');
        var spl = segment.el.find('.ods-proper');
        var sil = segment.el.find('.ods-improper');
        var bars = segment.bars, order = segment.order;
        var iamount = 0;
        for (var i = 0, im = order.length; i < im; i++) {
            var bar = bars[order[i].n];
            if (pf[bar.flights]) {
                bar.el.appendTo(spl);
            } else {
                bar.el.appendTo(sil);
                iamount++;
            }
            if (bar.flights === sf) {
                bar.el.addClass('selected');
            }
        }
        var title = 'Варианты';
        if (iamount > 0) {
            var direction = s === 1 ? ('перелётом ' + this.options[0].human) : 'обратным перелётом';
            title = 'Совместимые с выбранным ' + direction + ' варианты';
        }
        var sitems = segment.el.find('.sort-items .link').removeClass('sortedby');
        var sorted = sitems.filter('[data-sort="' + this.sortby + '"]').addClass('sortedby');
        segment.title.html(title + ', отсортированные ' + sorted.html());
        sil.toggle(iamount > 0);
    }
},
sortSegments: function() {
    var sf = this.sortFunctions[this.sortby];
    for (var s = this.segments.length; s--;) {
        var segment = this.segments[s];
        segment.order.sort(sf);
    }
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
                el: item.clone(),
                flights: item.attr('data-flights'),
                carrier: item.attr('data-carrier'),
                shift: options.shift,
                dpt: options.dpt,
                arv: options.arv
            };
        });
    }
},
formatTime: function(t) {
    if (t < 0) t += 1440;
    var h = Math.floor((t % 1440) / 60), hh = h < 10 ? ('<span class="zero">0</span>' + h) : h;
    return hh + ':' + (t % 60 / 100).toFixed(2).substring(2);
},
sortFunctions: {
    price: function(a, b) {
        return (a.price - b.price) || (a.duration - b.duration) || (a.departure - b.departure);
    },
    duration: function(a, b) {
        return (a.duration - b.duration) || (a.price - b.price) || (a.departure - b.departure);
    },
    departures: function(a, b) {
        return (a.departure - b.departure) || (a.price - b.price) || (a.duration - b.duration);
    },
    carrier: function(a, b) {
        if (a.carrier > b.carrier) return 1;
        if (a.carrier < b.carrier) return -1;
        return (a.price - b.price) || (a.duration - b.duration) || (a.departure - b.departure);
    }
}
};
