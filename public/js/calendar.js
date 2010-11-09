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
    this.title = $('h2', this.el);
    this.makeDates();
    this.initDates();
    this.scroller = new app.CalendarScroller(this);
    $('.panel-reset', this.el.parent()).click(function(event) {
        event.preventDefault();
        self.selected.length = 0;
        self.update();
    });
    this.resetButton = $('<div class="reset-button"></div>').appendTo(this.el);
    this.resetButton.css('margin-top', this.container.offset().top - this.el.offset().top);
    this.resetButton.click(function() {
        self.selected.length = 0;
        self.update();
    });
    this.values = [];
},
makeDates: function() {
    this.container = $('.dates', this.el).hide().html('');
    var today = new Date();
    var curd = today.clone().shiftDays(1 - (today.getDay() || 7));
    var curt = curd.getTime();
    var actend = today.clone().shiftMonthes(6);
    var abt = today.getTime();
    var aet = actend.getTime() - 1;
    var end = actend.shiftDays((actend.getDay() == 1 ? 8 : 15) - (actend.getDay() || 7)).getTime();
    var month = undefined, dcounter = 0;
    this.dmyindex = {};
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
            this.dmyindex[dmy] = dcounter;
            day.attr('data-index', dcounter++);
        }
        month.append(day.append(label));
        curt = curd.shiftDays(1).getTime();
    }
    $('.month:odd', this.container).addClass('odd');
    this.dates = $('li:not(.inactive)', this.container);
    this.dates.eq(0).addClass('withmonth');
    this.container.show();
    this.csize = {
        w: this.container.parent().width(),
        h: this.container.height()
    };
    this.dsize = {
        w: 84,
        h: 51
    };     
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
            var doffset = el.offset();
            var dsegments = [], index = parseInt(el.attr('data-index'), 10);
            var dragall = !el.hasClass('selected');
            for (var i = self.selected.length; i--;) {
                dsegments[i] = (dragall || self.selected[i] == index) ? 1 : 0;
            }
            var dx = e.pageX - doffset.left;
            var dy = e.pageY - doffset.top;  
            var coffset = self.container.offset();
            self.dragging = {
                el: el,
                index: dragall ? parseInt(el.attr('data-index'), 10) : undefined,
                selected: self.selected.concat(),
                segments: dsegments,
                ox: e.pageX,
                oy: e.pageY,
                dx: dx,
                dy: dy,
                minx: coffset.left + dx - 15,
                maxx: coffset.left + dx + self.container.parent().width() - 69,
                miny: coffset.top + dy - 15,
                maxy: coffset.top + dy + self.container.height() - 36,
                offset: 0
            };
            e.preventDefault();
            $(window).mousemove(dragHandler).one('mouseup', function() {
                $(window).unbind('mousemove', dragHandler);
                self.dragOverlay.hide();
                self.dragOrigin.hide();
                if (self.dragging.marked) {
                    self.dragging.marked.removeClass('drag');
                }
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
    this.dragOverlay.css('left', x - d.dx - 4).css('top', y - d.dy - 2);
    if (!d.active) {
        d.active = true;
        var orpos = d.el.position();
        this.dragOverlay.show();
        this.dragOrigin.css('left', orpos.left).css('top', orpos.top + this.container.scrollTop()).show();
        if (d.index != undefined) {
            d.marked = this.dates.eq(d.index).addClass('drag');
        }
        this.resetButton.hide();
    }
    var offset = Math.round((x - d.ox) / 84) + Math.round((y - d.oy) / 51) * 7;
    if (offset != d.offset) {
        d.offset = offset;
        var md = this.dates.length - 1;
        if (d.marked) {
            d.marked.removeClass('drag');
        }
        if (d.index != undefined) {
            d.marked = this.dates.eq((d.index + offset).constrain(0, md)).addClass('drag');
        }
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
    this.values = [];
    for (var i = Math.max(this.selected.length, 2); i--;) {
        var d = this.selected[i];
        this.values[i] = d !== undefined ? this.dates.eq(d).attr('data-dmy') : '';
    }
    var items = this.selected.compact();
    var title = 'Выберите даты';
    if (items.length > 1) {
        var damount = items.last() - items[0] + 1;
        title = app.utils.plural(damount, ['Выбран ', 'Выбрано ', 'Выбрано ']) + damount + app.utils.plural(damount, [' день', ' дня', ' дней']);
    } else if (items.length) {
        title = 'Выбрано ' + this.dates.eq(items[0]).text();
    }
    this.title.text(title);
    this.scroller.updatePreview(items);
    this.showResetButton();
    search.update(this);
},
select: function(dates) {
    var updated = false;
    for (var i = dates.length; i--;) {
        var n = this.dmyindex[dates[i].value];
        if (n != this.selected[i]) {
            this.selected[i] = n;
            updated = true;
        }
    }
    if (updated) this.update();    
},
showResetButton: function() {
    var offset, items = this.selected.compact();
    if (items.length) {
        var loffset = this.dates.eq(items.last()).position();
        if (loffset && loffset.top > -1) {
            if (loffset.top < this.csize.h) {
                offset = loffset;
            } else if (items.length > 1) {
                var foffset = this.dates.eq(items[0]).position();
                if (foffset.top < this.csize.h) offset = {
                    left: this.csize.w - this.dsize.w,
                    top: this.csize.h - this.dsize.h
                };
            }
        }
    }
    var rb = this.resetButton;
    if (offset) {
        rb.css({
            'left': offset.left + this.dsize.w - 15,
            'top': offset.top - 7
        }).show();
        rb.visible = true;
    } else {
        rb.visible = false;
        rb.hide();
    }
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
    self.toggleArrows();
    if (cst == nst) {
        self.parent.showResetButton();
    } else {
        $({st: cst}).animate({st: nst}, {
            duration: 100 + Math.round(Math.abs(cst - nst) / 3),
            step: function() {
                el.scrollTop(this.st);
            },
            complete: function() {
                el.scrollTop(nst);
                self.parent.showResetButton();
                self.toggleArrows();                
            }
        });
    }
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
        var rb = self.parent.resetButton;
        if (rb.visible) {
            rb.visible = false;
            rb.hide();        
        }
    });
},
initArrows: function() {
    var self = this, stimer, cst, dir, vel;
    var scollStep = function() {
        if (vel < 15) vel++;
        self.el.scrollTop(cst + dir * vel);
        cst = self.el.scrollTop();
        self.display(cst);
    };
    var startScroll = function(d) {
        cst = self.el.scrollTop();
        vel = 0;
        dir = d;
        stimer = setInterval(scollStep, 30);
    };
    var stopScroll = function() {
        clearInterval(stimer);
        if (dir) self.scrollTo(self.snap(cst + (30 - vel) * dir));       
        dir = 0;
    };
    this.scrollbw = $('.scrollbw', this.parent.el).mousedown(function(event) {
        event.preventDefault();
        startScroll(-1);
    });
    this.scrollfw = $('.scrollfw', this.parent.el).mousedown(function(event) {
        event.preventDefault();
        startScroll(1);
    });
    this.scrollbw.bind("mouseout mouseup", stopScroll);
    this.scrollfw.bind("mouseout mouseup", stopScroll);
    this.stmax = this.el.get(0).scrollHeight - this.el.height();
    this.toggleArrows();
},
toggleArrows: function() {
    var st = this.el.scrollTop();
    this.scrollbw.toggleClass('enabled', st > 0);
    this.scrollfw.toggleClass('enabled', st < this.stmax);
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
    var fdate = this.parent.dates.first();
    var offset = Math.round((1 - parseInt(fdate.attr('data-dmy').substring(0,2), 10)) * self.factor);
    this.timeline.css('left', offset).show();
    this.preview = $('.preview', this.scroller).css('left', Math.round(fdate.prevAll('li').length * self.factor));
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
},
updatePreview: function(items) {
    this.preview.html('');
    for (var i = items.length; i--;) {
        $('<div class="date"></div>').css('left', Math.round(items[i] * this.factor)).appendTo(this.preview);
    }
    if (items.length > 1) {
        var pl = Math.round(items[0] * this.factor);
        var pw = Math.round((items.last() - items[0]) * this.factor);
        $('<div class="period"></div>').css('left', pl).width(pw).prependTo(this.preview);
    }
}
};

/* Constrain */
Number.prototype.constrain = function(min, max) {
    var n = this.valueOf();
    return (n < min) ? min : ((n > max) ? max : n);
};
