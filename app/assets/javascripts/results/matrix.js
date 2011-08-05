results.matrix = {
init: function(table) {
    this.el = $('#offers-matrix');
    var table = this.el.find('.offer-prices');
    var frow = table.get(0).rows[0];
    var cells = table.find('td');
    var selected = table.find('td.selected'); 
    var htimer, highlight = function(td) {
        hlcurrent.removeClass('current');
        hlcurrent = $(frow.cells[parseInt(td.attr('data-col'), 10)]).add(td.parent()).addClass('current');
    };
    var self = this;
    var hlcurrent = $('.current', table);
    $(table).delegate('td', 'mouseenter', function() {
        clearTimeout(htimer);
        highlight($(this));
    }).delegate('td', 'mouseleave', function() {
        htimer = setTimeout(function() {
            highlight(selected);
        }, 50);
    }).delegate('td.active', 'click', function() {
        if (!$(this).closest('.offer').hasClass('active-booking')) {
            selected.removeClass('selected').addClass('active');
            selected = $(this).addClass('selected').removeClass('active');
            results.showVariant($('#mv-' + $(this).attr('data-vid')));
        }
    });
    cells.each(function() {
        var c = $(this);
        c.attr('data-col', c.prevAll().length);
    });    
},
process: function() {
    var table = this.el.find('.offer-prices').hide();
    var ordates, origin = this.el.find('.matrix-origin');
    var mtab = $('#rtab-matrix');    
    table.find('td').html('').removeClass('cheap active');
    if (origin.length) {
        this.el.find('.offer').removeClass('expanded').addClass('collapsed');
        table.find('.direction').html(origin.html());
        orDates = origin.attr('data-dates').split(' ');
        mtab.show();
    } else {
        mtab.hide();
        if (results.selectedTab == 'matrix' || pageurl.tab == 'matrix') {
            results.selectedTab = 'featured';
        }
        table.attr('data-minprice', '');
        return;
    }
    var rows = table.get(0).rows;
    var findex = {}, fdate = Date.parseAmadeus(orDates[0]).shiftDays(-3);
    for (var i = 0; i < 7; i++) {
        $(rows[0].cells[i + 1]).html(this.date(fdate));
        findex[fdate.toAmadeus()] = i + 1;
        fdate.shiftDays(1);
    }
    if (orDates[1]) {
        table.removeClass('owmatrix');
        var tindex = {};
        var tdate = Date.parseAmadeus(orDates[1]).shiftDays(-3);
        for (var i = 0; i < 7; i++) {
            $(rows[i + 1].cells[0]).html(this.date(tdate));
            tindex[tdate.toAmadeus()] = i + 1;
            tdate.shiftDays(1);
        }
    } else {
        table.addClass('owmatrix');
        var tindex = undefined;
    }
    var cheap = undefined;
    var variants = this.el.find('.offer-variant').each(function(i) {
        var el = $(this);
        var summary = $.parseJSON(el.attr('data-summary'));
        var cn = findex[summary.dates[0]];
        var rn = (tindex && summary.dates[1]) ? tindex[summary.dates[1]] : 4;
        var vid = summary.dates.join('-');
        var cell = $(rows[rn].cells[cn]).html(el.find('td.cost dt').html()).addClass('active').attr('data-vid', vid);
        el.attr('id', 'mv-' + vid).attr('data-index', i);
        if (!cheap || summary.price < cheap.price) {
            cheap = {price: summary.price, cells: cell};
        } else if (summary.price === cheap.price) {
            cheap.cells = cheap.cells.add(cell);
        }
    });
    if (cheap.cells.length / variants.length < 0.6) {
        cheap.cells.addClass('cheap');
    }
    var current = $(rows[4].cells[4]);
    if (current.hasClass('active')) {
        current.click();
    } else {
        cheap.cells.eq(0).click();
    }
    table.attr('data-minprice', cheap.price).show();
},
date: function(date) {
    var dm = date.getDate() + '&nbsp;' + constants.monthes.genitive[date.getMonth()];
    var wd = constants.weekdays[(date.getDay() || 7) - 1];
    return '<h6>' + dm + '</h6><p>' + wd + '</p>';
}
};
