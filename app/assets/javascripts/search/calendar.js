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
    this.resetButton = this.container.find('.reset-button');
    this.resetButton.click(function() {
        self.selected.length = 0;
        self.update();
    });
    this.message = this.el.parent().find('.calendar-message');
    this.message.find('.cm-close .link').click(function() {
        self.message.hide();
    });
    this.values = [];
},
makeDates: function() {
    this.container = $('.dates', this.el).hide();
    var today = new Date(), stoday = new Date(this.container.attr('data-current'));
    if (Math.abs(today.getTime() - stoday.getTime()) > 172800000) {
        today.setTime(stoday.getTime()); // используем серверное время, если разница с клиентским больше 2 суток
    }
    var tt = today.getTime();
    var curd = today.clone().shiftDays(1 - (today.getDay() || 7));
    var curt = curd.getTime();
    var actend = today.clone().shiftMonthes(10);
    // Активируем сегодняшнюю дату с 9 до 20 по будням
    var workd = stoday.getDay() !== 0 && stoday.getDay() !== 6;
    var workt = stoday.getHours() > 9 && (stoday.getHours() + stoday.getMinutes() / 100) < 19.40;
    var abt = today.clone().shiftDays(workt ? 0 : 1).getTime();
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
        var label = $('<span class="label">' + date + '<span class="mtitle">&nbsp;' + constants.monthes.genitive[curd.getMonth()] + '</span></span>');
        if (curd.dayoff()) {
            label.addClass('dayoff');
        }
        if (date == 1) {
            day.addClass('withmonth');
        }
        if (curt < abt || curt > aet) {
            day.addClass('inactive');
            if (curt === tt) {
                day.addClass('withmonth withtoday');
                label.append('<span class="today">сегодня</span>');
            }
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
        w: 595,
        h: this.container.height()
    };
    this.dsize = {
        w: 85,
        h: 51
    };
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
            if (self.selected.length < self.selectedLimit) {
                self.selected.push(index);
                self.selected.sortInt();
            } else {
                self.selected = [index];
            }
            self.message.hide();
            self.savedSelected = undefined;
            self.update();
        }
    }).delegate(selector, 'mouseover', function() {
        if (self.dragging) return;
        var index = parseInt($(this).attr('data-index'), 10);
        if (self.selected.length < self.selectedLimit) {
            var items = self.selected.concat(index);
        } else {
            var items = [index];
        }
        self.highlight(items && items.compact(), index);
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
                maxx: coffset.left + dx + self.csize.w - 69,
                miny: coffset.top + dy - 15,
                maxy: coffset.top + dy + self.csize.h - 36,
                offset: 0
            };
            e.preventDefault();
            $('body').mousemove(dragHandler).one('mouseup', function() {
                $('body').unbind('mousemove', dragHandler).unbind('selectstart');
                self.dragOverlay.hide();
                self.dragOrigin.hide();
                if (self.dragging.marked) {
                    self.dragging.marked.removeClass('drag');
                }
                delete self.dragging;
                self.update();
            }).bind('selectstart', function() {
                return false;
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
            this.selected[i] = this.selected[i] !== undefined ? (d.selected[i] + offset * d.segments[i]).constrain(0, md) : undefined;
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
        if (d !== undefined) this.values[i] = this.dates.eq(d).attr('data-dmy');
    }
    var items = this.values.compact();
    var title = 'Выберите даты';
    if (items.length) {
        var tparts = [];
        for (var i = 0, im = items.length; i < im; i++) {
            var d = Date.parseAmadeus(items[i]);
            tparts.push(d.getDate() + ' ' + constants.monthes[im > 2 ? 'short' : 'genitive'][d.getMonth()]);
        }
        title = tparts.join(' — ');
        if (items.length === 2) {
            title = title.replace(/( [а-я]+)(?= — \d+\1)/, '');
        } else if (items.length > 2) {
            title = title.replace(/май/g, 'мая');
        }
    }
    var selected = this.selected.compact();
    if (selected.length && selected.length < this.selectedLimit) {
        var offset = this.dates.eq(selected[selected.length - 1]).position().top;
        if (offset > this.scroller.rheight * 3 - 1) {
            var st = this.scroller.el.scrollTop() + offset - this.scroller.rheight * 1;
            this.scroller.scrollTo(this.scroller.snap(st));
        }
    }
    this.title.html(title);
    this.scroller.updatePreview(selected);
    this.showResetButton();
    search.update(this);
},
select: function(dates) {
    var updated = false;
    if (this.dmyindex[dates[0]] === undefined) {
        this.showMessage('На выбранную дату (' + Date.parseAmadeus(dates[0]).human() + ') невозможно забронировать билеты. Выберите, пожалуйста, другую дату.');
        if (this.selected.length !== 0) {
            this.selected = [];
            updated = true;
        }
    } else {
        this.message.hide();
        for (var i = dates.length; i--;) {
            var n = this.dmyindex[dates[i]];
            if (n != this.selected[i]) {
                this.selected[i] = n;
                updated = true;
            }
        }
    }
    if (updated) {
        this.update();
    }
},
showMessage: function(text) {
    this.message.find('.cm-content').html(text);
    this.message.show().css({
        left: Math.round((this.el.width() - this.message.outerWidth()) / 2),
        top: Math.round((this.el.height() - this.message.outerHeight()) / 2)
    });
},
showResetButton: function() {
    var items = this.selected.compact();
    if (items.length) {
        var st = this.container.scrollTop();
        var foffset = this.dates.eq(items[0]).position();
        var loffset = this.dates.eq(items.last()).position();
        this.rboffset = {
            top: loffset.top + st,
            left: loffset.left + this.dsize.w,
            min: foffset.top + st
        };
        this.rbactive = true;
        this.rbtop = undefined;
        this.toggleResetButton();
    } else {
        this.rbactive = false;
        this.resetButton.hide();
    }
},
toggleResetButton: function() {
    if (this.rbactive && !this.dragging) {
        var st = this.container.scrollTop();
        if (this.rboffset.top > st + 25) {
            var t = this.rboffset.top;
            var l = this.rboffset.left;
            var bottom = st + this.csize.h - 25;
            var delta = bottom - this.rboffset.min;
            if (this.rboffset.top > bottom && delta > 0) {
                t = this.rboffset.min + delta - delta % this.dsize.h;
                l = this.csize.w;
            }
            if (t !== this.rbtop) {
                this.resetButton.css({top: t, left: l});
                this.rbtop = t;
            }
            this.resetButton.show();
        } else {
            this.resetButton.hide();
        }
    }
},
fillSelected: function() {
    var selected = this.selected.compact();
    if (this.filled) {
        this.filled.removeClass('selected period segment-1 segment-2 segment-3');
    }
    for (var i = selected.length; i--;) {
        var el = this.dates.eq(selected[i]).addClass('selected segment-' + (i + 1));
    }
    this.filled = selected.length ? this.dates.slice(selected[0], selected[selected.length - 1] + 1).addClass("period") : undefined;
},
highlight: function(items, index) {
    if (this.highlighted) {
        this.highlighted.removeClass('hover phover shover-1 shover-2 shover-3');
    }
    if (items) {
        items.sortInt();
        for (var i = items.length; i--;) {
            if (items[i] === index) {
                this.dates.eq(index).addClass('hover shover-' + (i + 1));
            }
        }
        this.highlighted = items.length && this.dates.slice(items[0], items[items.length - 1] + 1).addClass("phover");
    } else {
        delete this.highlighted;
    }
},
toggleMode: function(mode) {
    this.selectedLimit = {ow: 1, rt: 2, dw: 2, tw: 3}[mode];
    this.container.removeClass('owmode rtmode dwmode twmode').addClass(mode + 'mode');
    if (!this.savedSelected || this.selected.length > this.savedSelected.length) {
        this.savedSelected = this.selected.concat();
    }
    if (this.selectedLimit > this.selected.length && this.savedSelected && this.savedSelected.length > this.selected.length) {
        this.selected = this.savedSelected.concat();
    }
    this.selected.length = Math.min(this.selected.length, this.selectedLimit);
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
    this.factor = 1.6;
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
        self.parent.toggleResetButton();
    } else {
        $({st: cst}).animate({st: nst}, {
            duration: 100 + Math.round(Math.abs(cst - nst) / 3),
            step: function() {
                el.scrollTop(this.st);
            },
            complete: function() {
                el.scrollTop(nst);
                self.parent.toggleResetButton();
                self.toggleArrows();
            }
        });
    }
},
scrollToSelected: function() {
    var selected = this.parent.selected;
    if (selected.length > 0) {
        var cst = this.el.scrollTop();
        var dates = this.parent.dates;
        var ftop = dates.eq(selected[0]).position().top + cst;
        var ltop = dates.eq(selected[selected.length - 1]).position().top + cst;
        var nst = ftop + Math.min(0, (ltop - ftop) / 2 - this.rheight * 3);
        this.el.scrollTop(this.snap(nst));
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
        self.parent.toggleResetButton();
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
    var self = this, dates = $('ul.month li', this.parent.container), sw = Math.round(dates.length * self.factor);
    this.scroller = $('.scroller', this.parent.el).width(sw).css('left', Math.round((this.parent.el.width() - sw) / 2));
    this.timeline = $('.timeline', this.scroller).hide().html('');
    $('.month', this.el).each(function() {
        var mdate = $(this).data('monthyear');
        var mw = Math.round(Date.daysInMonth(mdate.month, mdate.year) * self.factor);
        var label = $('<span>').addClass('label').width(mw).text(constants.monthes.short[mdate.month]);
        $('<li>').width(mw).append(label).appendTo(self.timeline);
    });
    var first = this.parent.dates.eq(0), before = first.prevAll('li').length + first.closest('ul').prev('ul').find('li').length;
    this.timeline.css('left', Math.round((1 - parseInt(dates.eq(0).attr('data-dmy').substring(0,2), 10)) * self.factor)).show();
    this.preview = $('.preview', this.scroller).css('left', Math.round(before * self.factor));
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
            $('body').mousemove(drag).one('mouseup', function() {
                $('body').unbind('mousemove', drag);
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
        var el = $('<div class="date"></div>').addClass('segment-' + (i + 1));
        el.css('left', Math.round(items[i] * this.factor)).appendTo(this.preview);
    }
    if (items.length > 1) {
        var pl = Math.round(items[0] * this.factor);
        var pw = Math.round((items.last() - items[0]) * this.factor);
        $('<div class="period"></div>').css('left', pl).width(pw).prependTo(this.preview);
    }
}
};