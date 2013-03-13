var User = {
init: function() {
    var that = this;
    this.el = $('#user');
    this.el.find('.phuf-input').on('input keyup propertychange paste', function() {
        var empty = this.value === '';
        if (empty !== this.empty) {
            $(this).prev('label').toggle(this.empty = empty);
        }
    });
    this.el.on('click', function(event) {
        event.stopPropagation();
    });
    this.el.find('.phu-link').on('click', function() {
        that[that.el.hasClass('phu-active') ? 'hide' : 'show']();
    });
    this._hide = function(event) {
        if (event.type == 'click' || event.which == 27) that.hide();
    };
},
show: function() {
    var that = this;
    this.el.addClass('phu-active');
    setTimeout(function() {
        $w.on('click keydown', that._hide);
    }, 10);
},
hide: function() {
    this.el.removeClass('phu-active');
    $w.off('click keydown', this._hide);
}
};

$(function() {
    User.init();
});
