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
        if (that.edit.is(':visible')) {
            results.hide();
        } else {
            that.apply();
        }
    });
    this.height = this.el.height();
    this.el.height(this.height);
    this.el.find('.rh-left').width('+=0');
},
hide: function() {
    this.buttonEnabled.fadeOut(150);
    this.summary.fadeOut(150);
},
show: function(message, ready) {
    var that = this;
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
        if (data.fresh) {
            results.load();
        }
        results.show();
    }
},
position: function() {
    return this.el.position().top - 36;
}
};