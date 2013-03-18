var User = {
init: function() {
    this.el = $('#user');
    var logout = this.el.find('.phu-logout form');
    if (logout.length) {
        this.el.find('.phul-logout').on('click', function() {
            logout.submit();
        });
    } else {
        this.initPopup();
    }
},
initPopup: function() {
    var that = this;
    this.el.find('.phuf-input').on('input keyup propertychange paste', function() {
        var empty = this.value === '';
        if (empty !== this.empty) {
            $(this).prev('label').toggle(this.empty = empty);
        }
    });
    this.el.on('click', function(event) {
        event.stopPropagation();
    });
    this.el.find('.phu-control').on('click', function() {
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
