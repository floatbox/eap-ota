var hint = {
init: function() {
    var that = this;
    this.el = $('#hint').click(function(event) {
        event.stopPropagation();
    });
    this.content = this.el.find('.h-content');
    this.el.find('.h-close').click(function() {
        that.hide();
    });    
    this.selfhide = function(event) {
        if (event.type == 'click' || event.which == 27) that.hide();
    };
},
show: function(event, content) {
    var that = this;
    var w = $(window), wst = w.scrollTop();
    if (this.el.is(':visible')) {
        $('body').unbind('click keydown', this.selfhide);
        this.el.hide();
    }
    this.content.html(content);
    var ew = this.el.width(), eh = this.el.height();
    this.el.css({
        left: (event.pageX - this.el.width() - 20).constrain(15, w.width() - this.el.outerWidth() - 15),
        top: (event.pageY - 15).constrain(wst + 15, wst + w.height() - this.el.outerHeight() - 15)
    }).fadeIn(150);
    setTimeout(function() {
        $('body').bind('click keydown', that.selfhide);
    }, 20);
},
hide: function() {
    this.el.fadeOut(80);
    $('body').unbind('click keydown', this.selfhide);
}
};

$(function() {
    hint.init();
});