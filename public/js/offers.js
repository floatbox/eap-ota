$.extend(app.offers, {
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
    $('#offers-list').delegate('.offer-summary, .offer', 'click', function(event) {
        event.preventDefault();
        event.stopPropagation();
        var offer = $(this).closest('.offer');
        var details = offer.children('.offer-details');
        if (details.is(':hidden')) {
            offer.find('.offer-toggle a').toggle();
            details.slideDown(300);
        }
    });
    $('#offers-list').delegate('.collapse', 'click', function(event) {
        event.preventDefault();
        event.stopPropagation();
        $(this).closest('.offer').children('.offer-details').slideUp(150);
        $(this).hide().siblings().show();
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
    $('#offers-list').html(s);
    $('#offers-tab-all > a').text('Все ' + $('#offers-all').attr('data-amount'));
    this.showTab();
    $("#offers-results").removeClass("g-none");
},
showTab: function(v) {
    if (v) this.tab = v;
    var activeId = 'offers-' + this.tab;
    $('#offers-list').children().each(function() {
        $(this).toggleClass('g-none', $(this).attr('id') != activeId);
    });
}
});
