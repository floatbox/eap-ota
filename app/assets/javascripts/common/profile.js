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
    }).trigger('input');
    this.el.on('click', function(event) {
        event.stopPropagation();
    });
    this.el.find('.phu-control').on('click', function() {
        that[that.el.hasClass('phu-active') ? 'hide' : 'show']();
    });
    this._hide = function(event) {
        if (event.type == 'click' || event.which == 27) that.hide();
    };
    this.slider = this.el.find('.phu-slider');
    this.el.find('.phu-forgot-link').on('click', function(event) {
        event.preventDefault();
        var le = $('#signin-email');
        var re = $('#forgot-email');
        re.val(le.val()).trigger('input');
        that.el.find('.phu-forgot').show();
        that.slider.animate({left: -260}, 200, function() {
            re.focus();
        });
    });
    this.el.find('.phu-remember-link').on('click', function(event) {
        event.preventDefault();
        var password = $('#customer_password').val('').trigger('input');
        that.slider.animate({left: 0}, 200, function() {
            password.focus();
            that.el.find('.phu-forgot').hide();
        });
    });
    this.el.find('.phu-signup-link').on('click', function(event) {
        event.preventDefault();
        that.el.find('.phu-signup').slideDown(100, function() {
            $('#signup-email').focus();
        });
    });
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
    this.el.find('.phu-signup').hide();
    $w.off('click keydown', this._hide);
}
};

$(function() {
    User.init();
});
