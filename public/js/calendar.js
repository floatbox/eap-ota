/* Calendar */
app.Calendar = function(selector) {
    this.el = $(selector);
    this.init();
    return this;
};
app.Calendar.prototype = {
init: function() {
    var self = this;
    this.selected = [];
    this.selectedLimit = 2;
    this.makeDates();
    this.initDates();
    this.scroller = new app.CalendarScroller(this);
    $('.panel-reset', this.el.parent()).click(function(event) {
        event.preventDefault();
        self.selected.length = 0;
        self.update();
    });
},
makeDates: function() {
    this.container = $('.dates', this.el).hide().html('');
    var today = new Date();
    var curd = today.clone().shiftDays(1 - (today.getDay() || 7));
    var curt = curd.getTime();
    var actend = today.clone().shiftMonthes(6);
    var abt = today.getTime();
    var aet = actend.getTime() - 1;
    var end = actend.shiftDays(15 - (actend.getDay() || 7)).getTime();
    var month = undefined, dcounter = 0;
    while (curt < end) {
        var date = curd.getDate();
        if (!month || date == 1) {
            month = $('<ul>').addClass('month').appendTo(this.container);
            month.data('monthyear', {
                month: curd.getMonth(),
                year: curd.getFullYear()
            });
        }
        var dmy = curd.toAmadeus();
        var day = $('<li>').attr('data-dmy', dmy);
        var label = $('<span class="label">' + date + ' <span class="mtitle">' + app.constant.MNg[curd.getMonth()] + '</span></span>');
        if (curd.dayoff()) {
            label.addClass('dayoff');
        }
        if (date == 1) {
            day.addClass('withmonth');
        }
        if (curt < abt || curt > aet) {
            day.addClass('inactive');
        } else {
            day.attr('data-index', dcounter++);
        }
        month.append(day.append(label));
        curt = curd.shiftDays(1).getTime();
    }
    this.dates = $('li:not(.inactive)', this.container);
    this.dates.eq(0).addClass('withmonth');
    $('.month:odd', this.dates).addClass('odd');
    this.container.show();
},
selectiveSegment: function(index) {
    var nearest, unselected, items = this.selected;
    var limit = this.selectedLimit || items.length;
    for (var i = 0; i < limit + 1; i++) {
        if (items[i] === undefined) {
            if (unselected === undefined) unselected = i;
        } else {
            if (nearest === undefined || Math.abs(items[i] - index) < Math.abs(items[nearest] - index)) nearest = i;
        }
    }
    return unselected == this.selectedLimit ? nearest : unselected;
},
initDates: function() {
    var self = this, selector = 'li:not(.inactive)';
    var dragHandler = function(e) {
        self.dragSelected(e);
    };
    this.container.delegate(selector, 'click', function() {
        if (self.ignoreClick) {
            self.ignoreClick = false;
        } else {
            var index = parseInt($(this).attr('data-index'), 10);
            var segment = self.selectiveSegment(index);
            self.selected[segment] = index;
            self.selected.sortInt();
            self.savedSelected = undefined;
            self.update();
        }
    }).delegate(selector, 'mouseover', function() {
        if (self.dragging) return;
        var index = parseInt($(this).attr('data-index'), 10);
        var segment = self.selectiveSegment(index);
        var items = self.selected.concat();
        items[segment] = index;
        self.highlight(items && items.compact());
    }).delegate(selector, 'mousedown', function(e) {
        var el = $(this);
        if (el.hasClass('period')) {
            if (!self.dragOverlay) {
                self.dragOverlay = $('<div id="calendar-drag-overlay"></div>').appendTo('body');
                self.dragOrigin = $('<div class="drag-origin"></div>').appendTo(self.container);
            };
            var cel = self.container.parent(), coffset = cel.offset();
            var doffset = el.offset();
            var dsegments = [], index = parseInt(el.attr('data-index'), 10);
            var dragall = !el.hasClass('selected');
            for (var i = self.selected.length; i--;) {
                dsegments[i] = (dragall || self.selected[i] == index) ? 1 : 0;
            }
            self.dragging = {
                el: el,
                selected: self.selected.concat(),
                segments: dsegments,
                ox: e.pageX,
                oy: e.pageY,
                dx: e.pageX - doffset.left,
                dy: e.pageY - doffset.top,
                minx: coffset.left,
                maxx: coffset.left + cel.width(),
                miny: coffset.top,
                maxy: coffset.top + cel.height(),
                offset: 0
            };
            e.preventDefault();
            $(window).mousemove(dragHandler).one('mouseup', function() {
                $(window).unbind('mousemove', dragHandler);
                self.dragOverlay.hide();
                delete(self.dragging);
                self.update();
            });
        }
    }).delegate(selector, 'mouseup', function(e) {
        var d = self.dragging;
        if (d && d.active) {
            if (d.el.get(0) == this) self.ignoreClick = true;
            self.update();
        }
    }).mouseout(function() {
        self.highlight();
    });
},
dragSelected: function(e) {
    var d = this.dragging;
    var x = e.pageX.constrain(d.minx, d.maxx);
    var y = e.pageY.constrain(d.miny, d.maxy);
    this.dragOverlay.css('left', x - d.dx).css('top', y - d.dy);
    if (!d.active) {
        d.active = true;
        this.dragOverlay.show();
        this.dragOrigin.show();
    }
    var offset = Math.round((x - d.ox) / 84) + Math.round((y - d.oy) / 50) * 7;
    if (offset != d.offset) {
        d.offset = offset;
        var md = this.dates.length - 1;
        for (var i = this.selected.length; i--;) {
            this.selected[i] = (d.selected[i] + offset * d.segments[i]).constrain(0, md);
        }
        this.savedSelected = undefined;
        this.selected.sortInt();
        this.fillSelected();
    }
},
update: function() {
    this.fillSelected();
    this.highlight();
    var dates = {};
    for (var i = this.selected.length; i--;) {
        var d = this.selected[i];
        if (d !== undefined) dates['date' + (i + 1)] = this.dates.eq(d).attr('data-dmy');
    }
    app.search.update(dates, this);
},
fillSelected: function() {
    if (this.filled) this.filled.removeClass(function() {
        return this.className.match(/\b(period|selected|segment\d+)\b/g).join(' ');
    });
    var selected = this.selected.compact();
    for (var i = selected.length; i--;) {
        this.dates.eq(selected[i]).addClass('selected segment' + i);
    }
    this.filled = selected.length && this.dates.slice(selected[0], selected[selected.length - 1] + 1).addClass("period");
},
highlight: function(items) {
    if (this.highlighted) this.highlighted.removeClass(function() {
        return this.className.match(/\b(p?hover|s\d+hover)\b/g).join(' ');
    });
    if (items) {
        for (var i = items.length; i--;) {
            this.dates.eq(items[i]).addClass('hover s' + i + 'hover');
        }
        items.sortInt();
        this.highlighted = items.length && this.dates.slice(items[0], items[items.length - 1] + 1).addClass("phover");
    } else {
        delete(this.highlighted);
    }
},
toggleOneway: function(mode) {
    this.selectedLimit = mode ? 1 : 2;
    if (!this.savedSelected || this.selected.length > this.savedSelected.length) {
        this.savedSelected = this.selected.concat();
    }
    if (this.selectedLimit > this.selected.length && this.savedSelected && this.savedSelected.length > this.selected.length) {
        this.selected = this.savedSelected.concat();
    }
    this.selected.length = this.selectedLimit;
    this.update();
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
    var self = this, dates = $('ul.month li', this.parent.container);
    this.scroller = $('.scroller', this.parent.el).width(Math.round(dates.length * self.factor));
    this.timeline = $('.timeline', this.scroller).hide().html('');
    $('.month', this.el).each(function() {
        var mdate = $(this).data('monthyear');
        var mw = Math.round(Date.daysInMonth(mdate.month, mdate.year) * self.factor);
        var label = $('<span>').addClass('label').width(mw).text(app.constant.SMN[mdate.month]);
        $('<li>').width(mw).append(label).appendTo(self.timeline);
    });
    var offset = Math.round((1 - parseInt(this.parent.dates.first().attr('data-dmy').substring(0,2), 10)) * self.factor);
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

/* Constrain */
Number.prototype.constrain = function(min, max) {
    var n = this.valueOf();
    return (n < min) ? min : ((n > max) ? max : n);
};
