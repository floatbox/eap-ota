/* Dates */
Date.prototype.clone = function() {
    return new Date(this.getTime());
};
Date.prototype.shift = function(days) {
    this.setDate(this.getDate() + days);
    return this;
};
Date.prototype.dayoff = function() {
    var dow = this.getDay();
    return (dow == 0 || dow == 6);
};
Date.prototype.toAmadeus = function() {
    var d = this.getDate();
    var m = this.getMonth() + 1;
    var y = this.getFullYear() % 100;
    return [d < 10 ? '0' : '', d, m < 10 ? '0' : '', m, y].join('');
};
Date.parseAmadeus = function(str) {
    var d = parseInt(str.substring(0,2), 10);
    var m = parseInt(str.substring(2,4), 10) - 1;
    var y = parseInt(str.substring(4,6), 10) + 2000;
    return new Date(y, m, d);
};
Date.daysInMonth = function(m, y) {
    var date = new Date(y, m, 1);
    date.setMonth(m + 1);
    date.setDate(0);
    return date.getDate();
};

/* Calendar date */
app.CalendarDate = function(type, parent) {
    this.parent = parent;
    this.type = type;
    this.date = null;
    return this;
}
app.CalendarDate.prototype = {
val: function(date) {
    if (arguments.length) {
        var dn = date && this.parent.index[date];
        console.log(date, dn);
        this.select(dn !== undefined && this.parent.days[dn]);
    } else if (this.el) {
        return this.el.attr("data-dmy");
    } else {
        return undefined;
    }
},
select: function(el, stealth) {
    if (this.el) this.el.removeClass(this.type);
    this.el = el && $(el).addClass(this.type);
    this.index = el ? this.el.data("index") : undefined;
    if (el && this.parent.savedRet) this.parent.savedRet = null;
    if (!stealth) this.parent.update();
}
};

/* Calendar scroll */
app.CalendarScroller = function(parent) {
    this.parent = parent;
    this.init();
    return this;
}
app.CalendarScroller.prototype = {
init: function() {
    this.el = this.parent.dates;
    this.rheight = $(this.parent.days[0]).outerHeight();
    this.active = true;
    this.factor = 1.5
    this.initNative();
    this.initTimeline();
    this.initScrollbar();
    this.initArrows();
},
snap: function(y) {
    return Math.round(y / this.rheight) * this.rheight;
},
scrollTo: function(nst) {
    var self = this, el = this.el, cst = el.scrollTop();
    if (cst == nst) return;
    $({st: cst}).animate({st: nst}, {
        duration: 100 + Math.round(Math.abs(cst - nst) / 3),
        step: function() {
            el.scrollTop(this.st);
        },
        complete: function() {
            el.scrollTop(nst);
        }
    });
},
initNative: function() {
    var self = this, atimer, pst;
    var cst = this.el.scrollTop();
    var align = function() {
        self.scrollTo(self.snap(cst + 15 * (cst - pst).constrain(-1, 1)));
    };
    this.el.scroll(function() {
        clearTimeout(atimer);
        pst = cst;
        cst = $(this).scrollTop();
        if (self.active) {
            self.display(cst);
            atimer = setTimeout(align, 500);
        }
    });
},
initArrows: function() {
    var self = this, stimer, cst, dir, vel;
    $('.scrollfw, .scrollbw', this.parent.el).mousedown(function(event) {
        event.preventDefault();
        dir = $(this).is(".scrollfw") ? 1 : -1;
        cst = self.el.scrollTop();
        vel = 0;
        stimer = setInterval(function() {
            if (vel < 15) vel++;
            self.el.scrollTop(cst + dir * vel);
            cst = self.el.scrollTop();
            self.display(cst);
        }, 30);
    }).bind("mouseout mouseup", function() {
        clearInterval(stimer);
        if (dir) {
            self.scrollTo(self.snap(cst + (30 - vel) * dir));       
            dir = 0;
        }
    });
},
initTimeline: function() {
    var self = this, mdate, days = this.parent.days, mw, sw = 0;
    this.scroller = $('.scroller', this.parent.el).width(Math.round(days.length * self.factor));
    this.timeline = $('.timeline', this.scroller).hide().html('');
    $('.month', this.el).each(function() {
        mdate = $(this).data('monthyear');
        mw = Math.round(Date.daysInMonth(mdate.month, mdate.year) * self.factor) - 1;
        var label = $('<span>').addClass('label').width(mw).text(app.constant.SMN[mdate.month]);
        $('<dt>').width(mw).append(label).appendTo(self.timeline);
        sw += mw + 1;
    });
    var monthes = $('dt', this.timeline);
    var offset = Math.round((1 - parseInt(days[0].children('span').text(), 10)) * self.factor);
    $('<div>').addClass('overlay').css('left', -offset - 51).appendTo(monthes.first());
    $('<div>').addClass('overlay').css('left', this.scroller.width() - offset - sw + mw).appendTo(monthes.last());
    this.timeline.append($('<dd>').text(mdate.year));
    this.timeline.css('left', offset).show();
},
initScrollbar: function() {
    var self = this;
    var sbw = 42 * this.factor;
    var sbf = 7 * this.factor / this.rheight;
    var sbm = this.scroller.width() - sbw;
    var scrollbar = $('.scrollbar', this.scroller).width(sbw);
    this.display = function(st) {
        scrollbar.css("left", Math.round(st * sbf));
    }
    this.scroller.mousedown(function(event) {
        event.preventDefault();
        var dragfrom = event.pageX;
        var sboffset = dragfrom - scrollbar.offset().left;
        if (sboffset > 0 && sboffset < sbw) {
            self.active = false;
            var sborigin = scrollbar.position().left;
            var drag = function(event) {
                var sbl =  (sborigin + event.pageX - dragfrom).constrain(0, sbm);
                scrollbar.css('left', sbl);
                self.el.scrollTop(sbl / sbf);
            };
            $(window).mousemove(drag).one('mouseup', function() {
                $(window).unbind('mousemove', drag);
                self.active = true;
                self.scrollTo(self.snap(self.el.scrollTop()));
            });
        }
    }).click(function(event) {
        var x = event.pageX - $(this).offset().left - sbw / 2;
        self.scrollTo(self.snap(x.constrain(0, sbm) / sbf));
    });     
}
};

/* Calendar */
app.Calendar = function(selector) {
    this.el = $(selector);
    this.init();
    return this;
};
app.Calendar.prototype = {
init: function() {
    var self = this;
    this.dpt = new app.CalendarDate("dpt", this);
    this.ret = new app.CalendarDate("ret", this);
    this.oneway = false;
    this.hlable = false;
    this.makeDates();
    this.initDates();
    this.scroller = new app.CalendarScroller(this);
    $('.panel-reset', this.el.parent()).click(function(event) {
        event.preventDefault();
        self.dpt.select(undefined, true);
        self.ret.select(undefined, true);
        self.update();
    });
},
makeDates: function() {
    this.dates = $('.dates', this.el).hide().html('');
    var today = new Date();
    var cd = today.clone().shift(1 - (today.getDay() || 7));
    var ld = today.clone();
    ld.setMonth(ld.getMonth() + 6);
    var tt = today.getTime();
    var ct = cd.getTime();
    var lt = ld.getTime() - 1;
    var et = ld.shift(15 - (ld.getDay() || 7)).getTime();
    var month = undefined, counter = 0, days = [];
    var index = {};
    while (ct < et) {
        var date = cd.getDate();
        if (!month || date == 1) {
            month = $('<ul>').addClass('month').data('monthyear', {
                month: cd.getMonth(),
                year: cd.getFullYear()
            }).appendTo(this.dates);
        }
        var dmy = cd.toAmadeus();
        var day = $("<li>").data('index', counter).attr('data-dmy', dmy);
        if (ct < tt || ct > lt) {
            day.addClass('inactive');
        }
        var label = $('<span>').text(date);
        if (cd.dayoff()) {
            label.addClass('dayoff');
        }
        month.append(day.append(label));
        days[counter] = day;
        index[dmy] = counter++;
        ct = cd.shift(1).getTime();
    }
    $('.month:odd', this.dates).addClass('odd');
    this.index = index;
    this.days = days;
},
initDates: function() {
    var self = this;
    this.dates.show().delegate('li:not(.inactive)', 'click', function() {
        if (self.dpt.el && self.ret.el) {
            self.nearest(this).select(this);
        } else if (self.oneway || !self.dpt.el) {
            self.dpt.select(this);
        } else {
            var n = $(this).data("index");
            if (n < self.dpt.index) {
                self.ret.select(self.days[self.dpt.index], true);
                self.dpt.select(this);
            } else {
                self.ret.select(this);
            }
        }
    }).delegate('li:not(.inactive)', 'mouseover', function() {
        var both = self.dpt.el && self.ret.el;
        var type = both ? self.nearest(this).type : (self.oneway || !self.dpt.el ? 'dpt' : 'ret');
        $(this).addClass(type + 'hover');
        if (self.hlable) self.highlight(this);
    }).delegate('li:not(.inactive)', 'mouseout', function() {
        $(this).removeClass('dpthover rethover');
    }).mouseout(function() {
        if (self.hlable) self.highlight();
    });
},
nearest: function(el) {
    if (this.dpt.el && this.ret.el) {
        var index = $(el).data('index');
        var dd = Math.abs(this.dpt.index - index);
        var dr = Math.abs(this.ret.index - index);
        return (index < this.dpt.index || dd < dr) ? this.dpt : this.ret;   
    } else if (this.dpt.el) {
        return this.dpt;
    } else if (this.ret.el) {
        return this.ret;
    } else {
        return undefined;
    }
},
update: function() {
    this.fill();
    this.highlight();
    this.hlable = !this.oneway && (this.dpt.el || this.ret.el);
    app.search.update({
        date1: this.dpt.val(),
        date2: this.ret.val()
    }, this);
},
fill: function() {
    $(".there", this.el).removeClass("there");
    if (this.dpt.el && this.ret.el) {
        var min = this.dpt.index + 1;
        var max = this.ret.index;
        for (var i = min; i < max; i++) {
            $(this.days[i]).addClass("there");
        }
    }
},
highlight: function(el) {
    $(".hl", this.el).removeClass("hl");
    if (el) {
        var n1 = this.nearest(el).index;
        var n2 = $(el).data("index");
        for (var i = Math.min(n1, n2), lim = Math.max(n1, n2); i < lim; i++) {
            $(this.days[i]).addClass("hl");
        }   
    }
},
toggleOneway: function(mode) {
    this.oneway = mode;
    if (mode && this.ret.el) {
        this.savedRet = this.ret.el;
        this.ret.select();
    }
    if (!mode && this.savedRet) {
        this.ret.select(this.savedRet);
        this.savedRet = undefined;
    }
}
};

/* Constrain */
Number.prototype.constrain = function(min, max) {
    var n = this.valueOf();
    return (n < min) ? min : ((n > max) ? max : n);
};
