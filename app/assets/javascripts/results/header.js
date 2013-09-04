/* Results header */
results.header = {
init: function() {
    var that = this;
    this.el = $('#results-header');
    this.wrapper = this.el.find('.rh-wrapper');
    this.summary = this.el.find('.rh-summary');
    this.button = $('#results-button');
    this.buttonEnabled = this.button.find('.rb-enabled');
    this.button.find('.rb-active').click(function() {
        that.apply();
    });
    this.select = this.el.find('.rh-select');
    this.edit = this.el.find('.rh-edit');
    this.edit.find('.rhe-link').click(function() {
        results.hide();
    });
    this.summary.on('click', '.rhs-text', function() {
        if (that.el.find('.rh-newsearch').length) {
            booking.newSearch();
        } else if (booking.el.is(':visible')) {
            booking.cancel();
        } else if (that.edit.is(':visible')) {
            results.hide();
        } else {
            that.apply();
        }
    });
    this.el.find('.rh-left').css('width', 960 - $('#search-options .so-cabin').width()); // Выравниваем кнопку по селектору класса
    this.loader = this.el.find('.rb-validating');
    this.height = this.el.height();
    preloadImages('/images/results/validating.gif');
},
hide: function() {
    this.buttonEnabled.fadeOut(150);
    this.summary.fadeOut(150);
},
show: function(message, ready) {
    var that = this;
    clearTimeout(this.showLoader);
    this.loader.hide();
    this.summary.queue(function(next) {
        that.summary.css('font-size', '');
        that.summary.css('line-height', '');
        if (ready) {
            that.summary.addClass('rh-ready').html('<span class="rhs-text">' + message + '</span>');
            that.adjust();
            that.buttonEnabled.fadeIn(150);
        } else {
            that.summary.removeClass('rh-ready').html(message);
        }
        next();
    }).fadeIn(150);
},
wait: function() {
    var that = this;
    this.showLoader = setTimeout(function() {
        that.loader.show();
    }, 500); 
},
adjust: function() {
    var size = 21;
    this.summary.css('visibility', 'hidden').show();
    while (this.summary.height() > 50 && size > 14) {
        this.summary.css('font-size', size);
        this.summary.css('line-height', Math.min(size + 2, 22) + 'px');
        size--;
    }
    this.summary.hide().css('visibility', '');
},
apply: function() {
    var data = results.data;
    if (data && data.valid) {
        // if (data.fresh) { только для новых условий поиска }
        results.load();
        results.show();
        var query = '/search?query=' + data.titles.header.replace(/&nbsp;/g, ' ');
        _kmq.push(['record', 'SEARCH: button pressed']);
        _gaq.push(['_trackPageview', query]);
        _yam.hit(query);        
    }
},
position: function() {
    return this.el.position().top - 62;
}
};