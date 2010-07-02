
// ======== индикатор загрузки ========

app.Loader = function(cfg) {
    this.cfg = $.extend({
        parent: null,
        type: 'dots'
    }, cfg);

    this.$el = $('<i/>')
    .addClass('loader')
    .addClass('loader-' + this.cfg.type)
    .hide()
    .appendTo(this.cfg.parent);
    
    return this;
}

app.Loader.prototype = {
    show: function() {
        this.$el.show();
    },

    hide: function() {
        this.$el.hide();
    }
}

