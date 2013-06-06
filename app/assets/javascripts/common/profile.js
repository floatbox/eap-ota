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
        this.initForms();
    }
},
initPopup: function() {
    var that = this;
    this.el.find('.phuf-input').on('focus', function() {
        $(this).prev('label').hide();
    }).on('blur input', function() {
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
    this.el.find('.phu-button').prop('disabled', false);
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
},
initForms: function() {

    var that = this;
    var checkEmail = function(value) {
        if (!value) return 'Введите адрес электронной почты.';
        if (/[а-яА-Я]/.test(value)) return 'Переключите раскладку и введите корректный адрес электронной почты.';
        if (!/@\S+\.\w+/.test(value)) return 'Введите корректный адрес электронной почты.';
    };

    var signIn = new profileForm(this.el.find('.phu-signin'));
    signIn.add('#signin-email', checkEmail);
    signIn.add('#signin-password', function(value) {
        if (!value) return 'Введите пароль.';
    });
    signIn.process = function(result) {
        window.location = result.location;
    };

    var signUp = new profileForm(this.el.find('.phu-signup'));
    signUp.add('#signup-email', checkEmail);
    signUp.process = function(result) {
        that.el.find('.phu-signup').closest('.phu-section').hide();
        that.el.find('.phu-signup-result').show();        
    };    
    
    var forgot = new profileForm(this.el.find('.phu-forgot'));
    forgot.add('#forgot-email', checkEmail);
    
}
};

var profileForm = function(elem) {
    var that = this;
    this.elem = elem;
    this.elem.on('submit', function(event) {
        event.preventDefault();
        if (that.validate()) {
            that.send();
        }
    });
    this.process = $.noop;
    this.button = this.elem.find('.phu-submit .phu-button');
    this.fields = [];
};
profileForm.prototype = {
validate: function() {
    var error;
    for (var i = 0, l = this.fields.length; i < l; i++) {
        this.fields[i].validate();
        if (!error) error = this.fields[i].error;
    }
    this.error(error);
    return !Boolean(error);
},
send: function() {
    var that = this;
    if (!this.button.prop('disabled')) {
        $.ajax(this.elem.attr('action'), {
            type: 'POST',
            data: this.elem.serialize()
        }).done(function(result) {
            if (result.success) {
                that.process(result);
            } else if (result.errors && result.errors.length) {
                that.button.prop('disabled', false);
                that.error(result.errors[0]);
            }
        }).fail(function(jqXHR, status, message) {
            that.button.prop('disabled', false);
            that.error(jqXHR.responseText);
        });
        this.button.prop('disabled', true);
    }
},
add: function(selector, check) {
    this.fields.push(new profileField(selector, check));
},
error: function(message) {
    this.elem.find('.phu-error').html(message || '').toggle(Boolean(message));
}
};

var profileField = function(selector, check) {
    var that = this;
    this.elem = $(selector);
    this.elem.on('focus change', function() {
        that.elem.removeClass('phuf-error');
    });
    this.check = check;
};
profileField.prototype = {
validate: function() {
    var value = this.elem.val();
    if (this.error = this.check(value)) {
        this.elem.addClass('phuf-error');
    } else {
        this.elem.removeClass('phuf-error');
    }
}
};

$(function() {
    User.init();
});
