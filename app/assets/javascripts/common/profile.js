var User = {
init: function() {
    this.el = $('#user');
    var logout = this.el.find('.phu-logout form');
    if (logout.length) {
        this.el.find('.phul-logout').on('click', function() {
            logout.submit();
        });
        this.show = $.noop;
    } else {
        this.initPopup();
        this.authorization.init();
        this.password.init();
        this.initPlaceholders();
    }
    this.init = $.noop;
},
initPopup: function() {
    var that = this;
    this.el.find('.phu-popup').on('click', function(event) {
        event.stopPropagation();
    });
    this.el.find('.phu-control').on('click', function(event) {
        event.stopPropagation();
        that[that.el.hasClass('phu-active') ? 'hide' : 'show']();
    });
    this._hide = function(event) {
        if (event.type == 'click' && !event.button || event.which == 27) that.hide();
    };
},
initPlaceholders: function() {
    var fields = this.el.find('.phuf-input');
    if (!('placeholder' in fields.get(0))) {
        this.el.find('.phuf-input').on('focus', function() {
            $(this).prev('label').hide();
        }).on('blur change', function() {
            $(this).prev('label').toggle(this.value === '');
        }).trigger('change');
    }
},
show: function(id) {
    var that = this;
    this.el.addClass('phu-active');
    this.opened = this[id || 'authorization'].el.show();
    this.opened.find('.phuf-input').trigger('change');    
    setTimeout(function() {
        $w.on('click keydown', that._hide);
    }, 10);
},
hide: function() {
    this.el.removeClass('phu-active');
    this.opened.hide();
    $w.off('click keydown', this._hide);
},
};

/* Authorization popup */
User.authorization = {
init: function() {

    var that = this;

    this.el = $('#phup-authorization');
    this.slider = this.el.find('.phu-slider');

    /* Form switchers */
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
    this.el.on('click', '.phu-signin-link', function() {
        if ($(this).hasClass('phust-link')) that.openSignIn();
    });
    this.el.on('click', '.phu-signup-link', function() {
        if ($(this).hasClass('phust-link')) that.openSignUp();
    });
    
    this.initForms();    
    
},
openSignIn: function() {
    var elem = this.el;
    $('#signin-email').val($('#signup-email').val()).trigger('blur');
    elem.find('.phus-title .phu-signin-link').removeClass('phust-link');
    elem.find('.phu-signup').slideUp(150);
    elem.find('.phu-stator').animate({
        height: elem.find('.phu-slider').height()
    }, 150, function() {
        elem.find('.phus-title .phu-signup-link').addClass('phust-link');
        $(this).height('');
    });
},
openSignUp: function() {
    var elem = this.el;
    $('#signup-email').val($('#signin-email').val()).trigger('blur');
    elem.find('.phus-title .phu-signup-link').removeClass('phust-link');
    elem.find('.phu-signup').slideDown(150);
    elem.find('.phu-stator').animate({height: 41}, 150, function() {
        elem.find('.phus-title .phu-signin-link').addClass('phust-link');
        elem.find('.phu-slider').css('left', 0);
    });
},
initForms: function() {

    var that = this;
    var checkEmail = function(value, full) {
        if (full) { 
            if (!value) return 'Введите адрес электронной почты.';
            if (!/^\S+@\S+\.\w+$/.test(value)) return 'Недействительный адрес электронной почты. Введите корректный адрес.';
        } else if (value) {
            if (/[а-яА-Я]/.test(value)) return 'Адрес электронной почты может содержать только латинские символы.';
        }
    };

    var signIn = new profileForm(this.el.find('.phu-signin'));
    signIn.add('#signin-email', checkEmail);
    signIn.add('#signin-password', function(value, full) {
        if (full && !value) return 'Введите пароль.';
    });
    signIn.process = function(result) {
        window.location = result.location;
    };
    signIn.messages['not_confirmed'] = '<p>Вы не завершили регистрацию. Для завершения регистрации перейдите по&nbsp;ссылке из&nbsp;письма-подтверждения.</p><p><a href="/profile/verification/new">Что делать, если ничего не&nbsp;пришло?</a></p>';
    signIn.messages['not_found'] = '<p>Пользователь с&nbsp;таким адресом не&nbsp;зарегистрирован.</p><p><span class="phu-signup-link phust-link">Зарегистрироваться</span></p>';
    signIn.messages['failed'] = function() {
        var value = $('#signin-password').val();
        var again = value === value.toUpperCase() ? 'Проверьте, не&nbsp;нажата&nbsp;ли клавиша Caps&nbsp;Lock, и&nbsp;попробуйте ещё раз.' : 'Попробуйте еще раз.';
        return 'Неправильная пара логин-пароль. ' + again;
    };
    
    var signUp = new profileForm(this.el.find('.phu-signup'));
    signUp.add('#signup-email', checkEmail);
    signUp.process = function(result) {
        that.el.find('.phu-signup').closest('.phu-section').hide();
        that.el.find('.phu-signup-result').show();
    };    
    signUp.messages['exist'] = '<p>Пользователь с таким адресом уже зарегистрирован.</p><p><span class="phu-signin-link phust-link">Войти</span></p>';
    signUp.messages['not_confirmed'] = '<p>Вы не завершили регистрацию. Для завершения регистрации перейдите по&nbsp;ссылке из&nbsp;письма-подтверждения.</p><p><a href="/profile/verification/new">Что делать, если ничего не&nbsp;пришло?</a></p>';

    this.el.find('.phusur-what-link .link').on('click', function() {
        that.el.find('.phusur-what-link').hide();
        that.el.find('.phusur-what').show();
    });
    this.el.find('.phusur-what .link').on('click', function() {
        that.el.find('.phu-signup-result').hide();
        that.el.find('.phusur-what-link').show();
        that.el.find('.phusur-what').hide();
        that.el.find('.phu-signup').closest('.phu-section').show();
        signUp.button.prop('disabled', false);        
    });

    var forgot = new profileForm(this.el.find('.phu-forgot'));
    forgot.add('#forgot-email', checkEmail);
    forgot.process = function() {
        that.el.find('.phu-forgot-fields').hide();
        that.el.find('.phu-forgot-result').show();
    };
    forgot.messages['not_found'] = '<p>Пользователь с&nbsp;таким адресом не&nbsp;зарегистрирован.</p><p><span class="phu-signup-link phust-link">Зарегистрироваться</span></p>';    

    this.el.find('.phufr-what-link .link').on('click', function() {
        that.el.find('.phufr-what-link').hide();
        that.el.find('.phufr-what').show();
    });
    this.el.find('.phufr-what .link').on('click', function() {
        that.el.find('.phu-forgot-result').hide();
        that.el.find('.phufr-what-link').show();
        that.el.find('.phufr-what').hide();
        that.el.find('.phu-forgot-fields').show();
        forgot.button.prop('disabled', false);
    });
    
    $('#signin-email, #signup-email, #forgot-email').on('focus', function() {
        if (this.value && /[а-яА-Я]/.test(this.value)) $(this).val('');
    }).on('change', function() {
        $(this).val($.trim(this.value));
    });    

}
};

/* Password popup */
User.password = {
init: function() {
    
    this.el = $('#phup-password');
    
    var compare = function() {
        var p1 = $('#new-password-1').val();
        var p2 = $('#new-password-2').val();
        if (p1 && p2 && p1 != p2) {
            return 'Введенные пароли не совпадают, вы ошиблись при наборе. Повторите попытку.';
        }
    };

    var form = new profileForm(this.el.find('form'));
    form.add('#new-password-1', function(value) {
        if (!value) return 'Введите пароль.';
        return compare();
    });
    form.add('#new-password-2', function(value) {
        if (!value) return 'Введите пароль ещё раз.';
        return compare();
    });
    form.process = function(result) {
        window.location = result.location;
    };    
    
    $('#new-password-1, #new-password-2').on('correct', function() {
        var p1 = $('#new-password-1');
        var p2 = $('#new-password-2');
        if (p1.val() && p2.val()) {
            p1.val('').removeClass('phuf-error');
            p2.val('').removeClass('phuf-error');
        };
    });  
    
},
use: function(token) {
    $('#customer_confirmation_token').val(token);
}
};

/* Form with ajax */
var profileForm = function(elem) {
    var that = this;
    this.elem = elem;
    this.elem.on('submit', function(event) {
        event.preventDefault();
        if (that.validate(true)) {
            that.send();
        }
    });
    this.process = $.noop;
    this.error = this.elem.find('.phu-error');
    this.button = this.elem.find('.phu-submit .phu-button').prop('disabled', false);
    this.fields = [];
    this.messages = {};
};
profileForm.prototype = {
validate: function(full) {
    this.errors = [];
    for (var i = 0, l = this.fields.length; i < l; i++) {
        var f = this.fields[i];
        if (full) f.validate(true);
        if (f.error) this.errors.push(f.error);
    }
    if (this.errors.length !== 0) {
        this.error.html(this.errors[0]).show();
        return false;
    } else {
        this.error.hide();
        return true;
    }
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
                that.showError(result.errors[0]);
            }
        }).fail(function(jqXHR, status, message) {
            that.button.prop('disabled', false);
            that.showError(jqXHR.statusText);
        });
        this.button.prop('disabled', true);
    }
},
add: function(selector, check) {
    this.fields.push(new profileField(selector, check, this));
},
showError: function(message) {
    var custom = this.messages[message];
    this.error.html(typeof custom === 'function' ? custom() : (custom || message)).show();
    for (var i = this.fields.length; i--;) {
        this.fields[i].error = ''; // Чтобы при редактировании полей пропало сообщение
    }
}
};

var profileField = function(selector, check, form) {
    var that = this;
    this.form = form;
    this.elem = $(selector);
    this.elem.on('input change', function() {
        var error = that.check(this.value);
        if (error !== that.error) {
            that.error = error;
            that.update();
            that.form.validate();
        }
    });
    this.check = check;
};
profileField.prototype = {
validate: function(full) {
    this.error = this.check(this.elem.val(), full);
},
update: function() {
    this.elem.toggleClass('phuf-error', Boolean(this.error));
}
};

$(function() {
    User.init();
});
