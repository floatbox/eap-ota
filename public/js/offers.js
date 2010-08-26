$.extend(app.offers, {
options: {},
init: function() {
    
    // Табы
    $('#offers-tabs').bind('select', function(e, v) {
        app.offers.showTab(v);
    }).radio({
        toggleClosest: 'li'
    });
    this.tab = 'best';

    // Подсветка
    $('#offers-list').delegate('.offer', 'mouseover', function() {
        $(this).addClass('hover');
    }).delegate('.offer', 'mouseout', function() {
        $(this).removeClass('hover');
    });
    
    // Подробности
    $('#offers-list').delegate('.expand', 'click', function(event) {
        var variant = $(this).closest('.offer-variant');
        var offer = variant.parent();
        if (offer.hasClass('collapsed')) {
            offer.height(offer.height()).removeClass('collapsed').animate({
            	height: variant.height()
            }, 300, function() {
            	offer.height('auto').addClass('expanded');
            });
        }
    });
    $('#offers-list').delegate('.collapse', 'click', function(event) {
        $(this).closest('.offer').removeClass('expanded').addClass('collapsed');
    });
    
    // Выбор времени вылета
    $('#offers-list').delegate('td.variants a', 'click', function(event) {
        event.preventDefault();
        var current = $(this).closest('.offer-variant')
        var departures = current.attr('data-departures').split(' ');
        var sindex = parseInt($(this).attr('data-segment'), 10);
        var svalue = $(this).text().replace(':', '');
        departures[sindex] = svalue;
        var query = departures.join(' ');
        var match = null, half_match = null;
        current.siblings().each(function() {
            var variant = $(this);
            var vd = variant.attr('data-departures');
            if (vd == query) {
                match = variant;
                return false;
            } else if (vd.split(' ')[sindex] == svalue) {
                half_match = variant;
            }
        });
        var variant = match || half_match;
        if (variant) {
            if (variant.hasClass('improper')) {
                alert('Выбранный вариант вылета не соответствует текущим фильтрам');
                variant.removeClass('improper');
            }
            current.addClass('g-none');
            variant.removeClass('g-none');
        }
    });
    
},
load: function(data) {
    var self = this;
    $("#offers-results").addClass("g-none");
    $("#offers-progress").removeClass("g-none");
    $("#offers").removeClass("g-none");
    $.get("/pricer/", {
        search: data
    }, function(s) {
        $("#offers-progress").addClass("g-none");
        if (typeof s == "string") {
            self.update(s);
        } else {
            alert(s && s.exception && s.exception.message);
        }
    });

},
update: function(s) {
    this.filterable = false;
    $('#offers-list').html(s);
    this.showAmount();
    this.showTab();
    $("#offers-results").removeClass('g-none');
    this.options = {};
    this.filterable = true;
},
showTab: function(v) {
    if (v) this.tab = v;
    var activeId = 'offers-' + this.tab;
    $('#offers-list').children().each(function() {
        $(this).toggleClass('g-none', $(this).attr('id') != activeId);
    });
},
filter: function(name, values) {
    var query = this.options;
    if (name) {
        if (values.length) {
            query[name] = values;
        } else {
            delete(query[name]);
        }
    }
    $('#offers-list .offer-variant').each(function() {
        var options = $.parseJSON($(this).attr('data-options'));
        var denied = false;
        for (var key in query) {
            var qvalues = query[key];
            var ovalues = options[key];
            if (!ovalues) continue;
            var values = {};
            for (var i = qvalues.length; i--;) {
                values[qvalues[i]] = true;
            }
            if (ovalues instanceof Array) {
                denied = true;
                for (var i = ovalues.length; i--;) {
                    if (values[ovalues[i]]) {
                        denied = false;
                        break;
                    }
                }
            } else {
                if (!values[ovalues]) denied = true;
            }
            if (denied) break;
        }
        if (denied) $(this).addClass('g-none');
        $(this).toggleClass('improper', denied);
    });
    $('#offers-list .offer').each(function() {
        var proper = $(this).children(':not(.improper)');
        $(this).toggleClass('improper', proper.length == 0);
        if (proper.length && proper.filter(':not(.g-none)').length == 0) proper.eq(0).removeClass('g-none');
    });
    this.showAmount($('#offers-all .offer:not(.improper)').length);
},
showAmount: function(amount) {
    var total = $('#offers-all').attr('data-amount');
    if (amount == undefined) amount = total;
    var str = amount + ' ' + app.utils.plural(amount, ['вариант', 'варианта', 'вариантов']);
    $('#offers-tab-all > a').text(amount == total ? ('Всего ' + str) : (str + ' из ' + total))
}
});
