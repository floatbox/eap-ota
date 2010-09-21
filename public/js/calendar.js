/* Dates */

// Date.prototype.clone, Date.prototype.shift и т.д. перенёс в utils.js
// все стандартные объекты портим в одном месте

/* Calendar scroll */
app.CalendarScroller = function(parent) {
    this.parent = parent;
    this.init();
    return this;
}
app.CalendarScroller.prototype = {
init: function() {
    this.el = this.parent.container;
    this.rheight = $(this.parent.dates.eq(0)).outerHeight();
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
    var self = this, mdate, mw, sw = 0;
    this.scroller = $('.scroller', this.parent.el).width(Math.round(this.parent.dates.length * self.factor));
    this.timeline = $('.timeline', this.scroller).hide().html('');
    $('.month', this.el).each(function() {
        mdate = $(this).data('monthyear');
        mw = Math.round(Date.daysInMonth(mdate.month, mdate.year) * self.factor) - 1;
        var label = $('<span>').addClass('label').width(mw).text(app.constant.SMN[mdate.month]);
        $('<dt>').width(mw).append(label).appendTo(self.timeline);
        sw += mw + 1;
    });
    var monthes = $('dt', this.timeline);
    var offset = Math.round((1 - parseInt(this.parent.dates.first().attr('data-dmy').substring(0,2), 10)) * self.factor);
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
        this.select(dn !== undefined && this.parent.days[dn]);
    } else if (this.el) {
        return this.el.attr("data-dmy");
    } else {
        return undefined;
    }
},
select: function(el, stealth) {
    this.el = el && $(el);
    this.index = el ? parseInt(this.el.attr('data-index'), 10) : undefined;
    if (el && this.parent.savedRet) this.parent.savedRet = null;
    if (!stealth) this.parent.update();
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
    this.container = $('.dates', this.el).hide().html('');
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
            }).appendTo(this.container);
        }
        var dmy = cd.toAmadeus();
        var day = $('<li>').attr('data-index', counter).attr('data-dmy', dmy);
        if (ct < tt || ct > lt) {
            day.addClass('inactive');
        }
        var label = $('<span>').text(date);
        if (cd.dayoff()) {
            label.addClass('dayoff');
        }
        month.append(day.append(label));
        index[dmy] = counter++;
        ct = cd.shift(1).getTime();
    }
    $('.month:odd', this.dates).addClass('odd');
    this.dates = $('li', this.container);
    var active = $('li:not(.inactive)', this.container);
    this.min = parseInt(active.first().attr('data-index'), 10);
    this.max = parseInt(active.last().attr('data-index'), 10);
},
initDates: function() {
    var self = this;
    this.container.show().delegate('li:not(.inactive)', 'click', function() {
        if (self.dpt.el && self.ret.el) {
            self.nearest(this).select(this);
        } else if (self.oneway || !self.dpt.el) {
            self.dpt.select(this);
        } else {
            var n = parseInt($(this).attr('data-index'), 10);
            if (n < self.dpt.index) {
                self.ret.select(self.dates.eq(self.dpt.index), true);
                self.dpt.select(this);
            } else {
                self.ret.select(this);
            }
        }
    }).delegate('li:not(.inactive)', 'mousedown', function(event) {
        event.preventDefault();
        var el = $(this), mode;
        if (el.hasClass('dpt')) mode = 'dpt';
        if (el.hasClass('ret')) mode = 'ret';
        if (!mode && el.hasClass('there')) mode = 'both';
        var dragselection = (!self.dpt.el && !self.ret.el && !self.oneway);
        var index = parseInt(el.attr('data-index'), 10);
        if (!mode && dragselection) mode = 'ret';
        if (mode) {
            self.dragging = {
                mode: mode,
                from: index,
                dpt: self.dpt.el ? self.dpt.index : (dragselection ? index : undefined),
                ret: self.ret.el ? self.ret.index : (dragselection ? index : undefined)
            };
            $(window).one('mouseup', function() {
                self.dragging = null;
            });
        }
    }).delegate('li:not(.inactive)', 'mouseup', function() {
        var sdc = self.dragging && self.dragging.current;
        if (sdc) {
            self.dpt.select(sdc.dpt, true);
            self.ret.select(sdc.ret, true);
            self.update();
        }
        self.dragging = null;
    }).delegate('li:not(.inactive)', 'mouseover', function() {
        if (self.dragging) {
            var d = self.dragging, offset = $(this).attr('data-index') - d.from, dptel, retel;
            var dpt = d.dpt !== undefined ? ((d.mode == 'dpt' || d.mode == 'both') ? (d.dpt + offset).constrain(self.min, self.max) : d.dpt) : undefined;
            var ret = d.ret !== undefined ? ((d.mode == 'ret' || d.mode == 'both') ? (d.ret + offset).constrain(self.min, self.max) : d.ret) : undefined;
            if (dpt !== undefined && ret !== undefined && ret < dpt) {
                dptel = self.dates.eq(ret);
                retel = self.dates.eq(dpt);
            } else {
                dptel = dpt !== undefined && self.dates.eq(dpt);
                retel = ret !== undefined && self.dates.eq(ret);
            }
            d.current = {dpt: dptel, ret: retel};
            self.fill(dptel, retel);
        } else {
            var both = self.dpt.el && self.ret.el;
            var type = both ? self.nearest(this).type : (self.oneway || !self.dpt.el ? 'dpt' : 'ret');
            if (self.hlable) self.highlight(this);
            $(this).addClass(type + 'hover');
        }
    }).delegate('li:not(.inactive)', 'mouseout', function() {
        $(this).removeClass('dpthover rethover');
    }).mousemove(function() {
        if (self.dragging) self.highlight();
    }).mouseout(function() {
        if (self.hlable) self.highlight();
    });
},
nearest: function(el) {
    if (this.dpt.el && this.ret.el) {
        var index = $(el).attr('data-index');
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
    this.fill(this.dpt.el, this.ret.el);
    this.highlight();
    this.hlable = !this.oneway && (this.dpt.el || this.ret.el);
    app.search.update({
        date1: this.dpt.val(),
        date2: this.ret.val()
    }, this);
},
fill: function(dpt, ret) {
    if (this.filled) this.filled.removeClass('dpt ret there');
    this.filled = null;
    if (dpt) this.filled = dpt.addClass('dpt');
    if (ret) this.filled = ret.addClass('ret');
    if (dpt && ret) {
        var dptindex = parseInt(dpt.attr('data-index'), 10);
        var retindex = parseInt(ret.attr('data-index'), 10);
        this.filled = this.dates.slice(dptindex, retindex + 1).addClass("there");
    }
},
highlight: function(el) {
    if (this.highlighted) this.highlighted.removeClass("hl");
    this.highlighted = null;
    if (el) {
        var n1 = this.nearest(el).index;
        var n2 = parseInt($(el).attr('data-index'), 10);
        this.highlighted = this.dates.slice(Math.min(n1, n2), Math.max(n1, n2)).addClass('hl');
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
