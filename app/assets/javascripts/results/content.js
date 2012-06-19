/* Results content */
results.content = {
init: function() {
    this.el = $('#results-content');
    this.initTabs();
    this.initOffers();
},
position: function() {
    return this.el.position().top - page.header.height - results.header.height;
},
initTabs: function() {
    var that = this;
    this.tabs = $('#results-tabs');
    this.tabs.delegate('li:not(.rt-selected, .rt-disabled)', 'click', function() {
        that.select($(this).closest('.rt-item').attr('data-tab'));
    });
    this.tabs.find('.rt-item').each(function() {
        var el = $(this), id = el.attr('data-tab');
        var collection = results[id];
        if (!collection) {
            collection = {};
            results[id] = collection;
        }
        collection.content = $('#results-' + id);
        collection.control = el;
        if (collection.init) {
            collection.init();
        }
    });
},
initOffers: function() {
    var that = this;
    this.el.delegate('.od-show', 'click', function() {
        that.getOffer($(this)).showDetails();
    });
    this.el.delegate('.od-hide', 'click', function() {
        that.getOffer($(this)).hideDetails();
    });
    this.el.delegate('.os-more', 'click', function() {
        $(this).closest('.o-segment').removeClass('hide-excess');
        results.fixed.move();
    });
    this.el.delegate('.od-alliance', 'click', function(event) {
        var el = $(this);
        hint.show(event, 'В альянс ' + el.html() + ' входят авиакомпании: ' + el.attr('data-carriers') + '.');
    });    
    this.el.delegate('.os-summary:not(.os-selected)', 'click', function() {
        var el = $(this);
        var offer = that.getOffer(el);
        var segment = el.closest('.o-segment').prevAll('.o-segment').length;
        offer.selectSegment(segment, el.attr('data-flights'));
        if (offer === booking.offer) {
            booking.abort();
        }
    });    
    this.el.delegate('.o-book .obb-title', 'click', function() {
        var offer = that.getOffer($(this));
        if (offer !== booking.offer) {
            booking.prebook(offer);
        }
    });
},
getOffer: function(el) {
    return el.closest('.offer').data('offer');
},
select: function(id) {
    booking.abort();
    if (id === 'matrix' || this.selected === 'matrix') {
        results.changeDates(id === 'matrix' && results.matrix.offer.selected.dates);
    }
    var that = this;
    setTimeout(function() { // без таймаута в файрфоксе мигает заголовок
        if (that.selected) {
            var ot = results[that.selected];
            ot.control.removeClass('rt-selected');
            ot.content.hide();
        }
        var nt = results[that.selected = id];
        nt.control.addClass('rt-selected');
        nt.content.show();
        results.fixed.update();
        page.location.set('offer', id === 'all' ? '' : id);
        results.filters.toggleDisabled(id === 'matrix');
        trackPage('/' + page.location.hash);
    }, 20);
},
selectFirst: function() {
    this.select(this.tabs.find('.rt-item:not(.rt-disabled)').attr('data-tab'));
}
};
