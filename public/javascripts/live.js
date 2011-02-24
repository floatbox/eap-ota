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
        s = [{"price":10861,"created_at":"2011-02-19T21:12:07+03:00","code":"3pDG3C","updated_at":"2011-02-19T21:12:07+03:00","url":"https://eviterra.com/#3pDG3C","id":958,"for_stats_only":false,"description":"\u041a\u0438\u0435\u0432 \u21c4 \u0421\u0442\u0430\u043c\u0431\u0443\u043b"},{"price":12819,"created_at":"2011-02-19T21:16:59+03:00","code":"3pCB3S","updated_at":"2011-02-19T21:16:59+03:00","url":"https://eviterra.com/#3pCB3S","id":959,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u21c4 \u0412\u0435\u043d\u0430"},{"price":5759,"created_at":"2011-02-19T21:18:29+03:00","code":"3pymQP","updated_at":"2011-02-19T21:18:29+03:00","url":"https://eviterra.com/#3pymQP","id":960,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u2192 \u0418\u043d\u0441\u0431\u0440\u0443\u043a"},{"price":12819,"created_at":"2011-02-19T21:19:51+03:00","code":"3pDjRR","updated_at":"2011-02-19T21:19:51+03:00","url":"https://eviterra.com/#3pDjRR","id":961,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u21c4 \u0412\u0435\u043d\u0430"},{"price":5759,"created_at":"2011-02-19T21:24:11+03:00","code":"3pBpKQ","updated_at":"2011-02-19T21:24:11+03:00","url":"https://eviterra.com/#3pBpKQ","id":962,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u2192 \u0418\u043d\u0441\u0431\u0440\u0443\u043a"},{"price":12422,"created_at":"2011-02-19T21:25:44+03:00","code":"3pxVwf","updated_at":"2011-02-19T21:25:44+03:00","url":"https://eviterra.com/#3pxVwf","id":963,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u21c4 \u0412\u0435\u043d\u0430"},{"price":12626,"created_at":"2011-02-19T21:27:08+03:00","code":"3pxqnV","updated_at":"2011-02-19T21:27:08+03:00","url":"https://eviterra.com/#3pxqnV","id":964,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u2192 \u0418\u043d\u0441\u0431\u0440\u0443\u043a"},{"price":5853,"created_at":"2011-02-19T21:28:49+03:00","code":"3pGhTB","updated_at":"2011-02-19T21:28:49+03:00","url":"https://eviterra.com/#3pGhTB","id":965,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u2192 \u041c\u044e\u043d\u0445\u0435\u043d"},{"price":7416,"created_at":"2011-02-19T21:46:30+03:00","code":"3pFb1G","updated_at":"2011-02-19T21:46:30+03:00","url":"https://eviterra.com/#3pFb1G","id":966,"for_stats_only":false,"description":"\u041a\u0440\u0430\u0441\u043d\u043e\u0434\u0430\u0440 \u21c4 \u0421\u0430\u043d\u043a\u0442-\u041f\u0435\u0442\u0435\u0440\u0431\u0443\u0440\u0433"},{"price":3512,"created_at":"2011-02-19T21:47:20+03:00","code":"3pC5vv","updated_at":"2011-02-19T21:47:20+03:00","url":"https://eviterra.com/#3pC5vv","id":967,"for_stats_only":false,"description":"\u0413\u0430\u043c\u0431\u0443\u0440\u0433 \u21c4 \u0410\u043c\u0441\u0442\u0435\u0440\u0434\u0430\u043c"},{"price":10781,"created_at":"2011-02-19T22:00:55+03:00","code":"3pBbdD","updated_at":"2011-02-19T22:00:55+03:00","url":"https://eviterra.com/#3pBbdD","id":968,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u21c4 \u0411\u0430\u0440\u0441\u0435\u043b\u043e\u043d\u0430"},{"price":10781,"created_at":"2011-02-19T22:03:27+03:00","code":"3pxL9H","updated_at":"2011-02-19T22:03:27+03:00","url":"https://eviterra.com/#3pxL9H","id":969,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u21c4 \u0411\u0430\u0440\u0441\u0435\u043b\u043e\u043d\u0430"},{"price":11285,"created_at":"2011-02-19T22:05:43+03:00","code":"3pyfzy","updated_at":"2011-02-19T22:05:43+03:00","url":"https://eviterra.com/#3pyfzy","id":972,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u21c4 \u0420\u0438\u043c"},{"price":13455,"created_at":"2011-02-19T22:07:10+03:00","code":"3pCnjL","updated_at":"2011-02-19T22:07:10+03:00","url":"https://eviterra.com/#3pCnjL","id":973,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u21c4 \u0420\u0438\u043c"},{"price":23809,"created_at":"2011-02-19T22:08:07+03:00","code":"3pzr6q","updated_at":"2011-02-19T22:08:07+03:00","url":"https://eviterra.com/#3pzr6q","id":974,"for_stats_only":false,"description":"\u041d\u0438\u0436\u043d\u0438\u0439 \u041d\u043e\u0432\u0433\u043e\u0440\u043e\u0434 \u21c4 \u0420\u0438\u043c"},{"price":2630,"created_at":"2011-02-19T22:08:44+03:00","code":"3pzkM6","updated_at":"2011-02-19T22:08:44+03:00","url":"https://eviterra.com/#3pzkM6","id":975,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u2192 \u041a\u0438\u0435\u0432"},{"price":25823,"created_at":"2011-02-19T22:09:11+03:00","code":"3pyQ07","updated_at":"2011-02-19T22:09:11+03:00","url":"https://eviterra.com/#3pyQ07","id":976,"for_stats_only":false,"description":"\u041d\u0438\u0436\u043d\u0438\u0439 \u041d\u043e\u0432\u0433\u043e\u0440\u043e\u0434 \u21c4 \u0420\u0438\u043c"},{"price":12911,"created_at":"2011-02-19T22:11:51+03:00","code":"3pBG1r","updated_at":"2011-02-19T22:11:51+03:00","url":"https://eviterra.com/#3pBG1r","id":977,"for_stats_only":false,"description":"\u041a\u0438\u0448\u0438\u043d\u0435\u0432 \u21c4 \u041b\u043e\u043d\u0434\u043e\u043d"},{"price":4440,"created_at":"2011-02-19T22:21:20+03:00","code":"3pxNSf","updated_at":"2011-02-19T22:21:20+03:00","url":"https://eviterra.com/#3pxNSf","id":978,"for_stats_only":false,"description":"\u041c\u043e\u0441\u043a\u0432\u0430 \u2192 \u0424\u0440\u0430\u043d\u043a\u0444\u0443\u0440\u0442"},{"price":54157,"created_at":"2011-02-19T22:31:36+03:00","code":"3pymn8","updated_at":"2011-02-19T22:31:36+03:00","url":"https://eviterra.com/#3pymn8","id":979,"for_stats_only":false,"description":"\u0421\u0430\u043c\u0430\u0440\u0430 \u21c4 \u0413\u0430\u0432\u0430\u043d\u0430"}];
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
