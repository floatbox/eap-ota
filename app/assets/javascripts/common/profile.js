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
    this.el.find('.phuf-input').on('focus', function() {
        $(this).prev('label').hide();
    }).on('blur', function() {
        $(this).prev('label').toggle(this.value === '');
    }).trigger('blur');
    this.el.on('click', function(event) {
        event.stopPropagation();
    });
    this.el.find('.phu-control').on('click', function() {
        that[that.el.hasClass('phu-active') ? 'hide' : 'show']();
    });
    this._hide = function(event) {
        if (event.type == 'click' && !event.button || event.which == 27) that.hide();
    };
    this.slider = this.el.find('.phu-slider');
    this.el.find('.phu-forgot-link').on('click', function(event) {
        event.preventDefault();
        var le = $('#signin-email');
        var re = $('#forgot-email');
        re.val(le.val()).trigger('blur');
        that.el.find('.phu-forgot').show();
        that.slider.animate({left: -260}, 200);
    });
    this.el.find('.phu-remember-link').on('click', function(event) {
        event.preventDefault();
        that.slider.animate({left: 0}, 200, function() {
            that.el.find('.phu-forgot').hide();
        });
    });
    this.el.find('.phu-signin-link').on('click', function(event) {
        var elem = $(this);
        if (elem.hasClass('phust-link')) {
            $('#signin-email').val($('#signup-email').val()).trigger('blur');
            elem.removeClass('phust-link');
            that.el.find('.phu-signup').slideUp(150);
            that.el.find('.phu-stator').animate({
                height: that.el.find('.phu-slider').height()
            }, 150, function() {
                that.el.find('.phu-signup-link').addClass('phust-link');
                $(this).height('');
            });
        }
    });
    this.el.find('.phu-signup-link').on('click', function(event) {
        var elem = $(this);
        if (elem.hasClass('phust-link')) {
            $('#signup-email').val($('#signin-email').val()).trigger('blur');
            elem.removeClass('phust-link');
            that.el.find('.phu-signup').slideDown(150);
            that.el.find('.phu-stator').animate({height: 41}, 150, function() {
                that.el.find('.phu-signin-link').addClass('phust-link');
                that.el.find('.phu-slider').css('left', 0);
            });
        }
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
    $w.off('click keydown', this._hide);
}
};

$(function() {
    User.init();
});
