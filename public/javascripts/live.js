search.live = {
init: function() {
    var that = this;
    this.el = $('#live');
    this.slider = this.el.find('.live-slider');
    this.self_move = function() {
        that.move();
    };
    this.el.mouseenter(function() {
        that.dv = -0.2;
    });
    this.el.mouseleave(function() {
        that.dv = 0.1;
    });
    this.el.delegate('a', 'click', function(event) {
        event.preventDefault();
        search.validate($(this).attr('data-key'));
    });
    this.stw = this.el.find('.live-stator').width();
    this.vmax = 2;
    this.vel = 2;
    this.slx = 0;
    this.dv = 0;
    this.update();
},
move: function() {
    var slx = this.slx - this.vel;
    if (slx !== this.slx) {
        this.slider.css('left', slx);
        this.slx = slx;
    }
    if (slx <= this.stw - this.slw) {
        this.proceed();
        this.update();
    }
    if (this.dv !== 0) {
        var v = this.vel + this.dv;
        if (v > 0 && v < this.vmax) {
            this.vel = v;
        } else {
            this.vel = v.constrain(0, this.vmax);
            this.dv = 0;
        }
    }
},
toggle: function(mode) {
    if (this.slw === undefined) mode = false;
    if (mode === this.active) return;
    if (mode) {
        this.timer = setInterval(this.self_move, 50);
        this.el.removeClass('latent');
    } else {
        clearInterval(this.timer);
        this.el.addClass('latent');
    }
    this.active = mode;
},
update: function() {
    var that = this;
    $.get('/hot_offers', function(s) {
        if (s && s.length) that.process(s);
    });
},
process: function(data) {
    var items = [], template = '<li><a href="/#{code}:featured" data-key="{code}">{description} от {hprice}</a></li>';
    for (var i = 0, im = data.length; i < im; i++) {
        var d = data[i];
        d.hprice = d.price.inflect('рубля', 'рублей', 'рублей')
        items.push(template.supplant(d));
    }
    this.actual = '<ul>' + items.join('') + '</ul>';
    if (this.slw === undefined) {
        this.proceed();
    }
    this.toggle(true);
},
proceed: function() {
    var groups = this.slider.children('ul');
    if (groups.length > 1) {
        groups.eq(0).remove();
        this.slx = this.stw - this.slider.width();
        this.slider.css('left', this.slx);
    }
    this.slider.append(this.actual);
    this.slw = this.slider.width();
}
};
