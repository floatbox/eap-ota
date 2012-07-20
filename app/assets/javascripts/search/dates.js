search.dates = {
init: function() {
    this.el = $('#search-dates');
    this.ssnow = new Date(this.el.attr('data-now'));
    this.csnow = new Date();
    if (Math.abs(this.csnow.getTime() - this.ssnow.getTime()) > 1000 * 60 * 60 * 12) {
        this.csnow = this.ssnow; // используем серверное время, если на клиенте неправильное
    }
    this.initCalendar();
    this.initTimeline();
    this.initScrolling();
    //this.initGestures();
    this.initDays();
},
initCalendar: function() {
    this.calendar = this.el.find('.sdc-content');
    this.slider = this.el.find('.sdc-slider');
    this.makeMonthes();
    this.disableDays();
    this.mwidth = this.monthes[0].el.width();
    this.overlay = this.el.find('.sdc-overlay');
},
makeMonthes: function() {
    this.slider.hide();
    var sample = this.el.find('.sdc-month');
    var date = new Date(this.csnow.getFullYear(), this.csnow.getMonth() - 1, 1);
    this.monthes = [];
    for (var m = 0; m < 12; m++) {
        date.setMonth(date.getMonth() + 2);
        date.setDate(0);
        var month = {
            year: date.getFullYear(),
            ntitle: local.date.nmonthes[date.getMonth()],
            gtitle: local.date.gmonthes[date.getMonth()],
            ptitle: local.date.pmonthes[date.getMonth()],
            length: date.getDate()
        };
        var MY = date.DMY().substring(2);
        var days = $('<div class="sdc-days"></div>');
        for (var d = 1, dm = month.length + 1; d < dm; d++) {
            var day = $('<div class="sdc-day"></div>');
            day.append('<div class="date">' + d + '</div>');
            day.append('<div class="month">' + month.gtitle + '</div>');
            day.attr('data-dmy', [d < 10 ? '0' : '', d, MY].join(''));
            days.append(day);
        }
        date.setDate(1);
        days.children().eq(0).addClass('first').css('margin-left', 66 * date.dow());
        month.el = sample.clone().data('index', m).append(days).appendTo(this.slider);
        this.monthes[m] = month;
    }
    sample.remove();
    this.slider.show();
},
disableDays: function(delay) {
    var d1 = this.csnow.getDate() - 1, d2;
    var days = this.calendar.find('.sdc-day');
    var time = parseFloat(this.el.attr('data-now').match(/ (\d\d:\d\d):\d\d/)[1].replace(':', '.'));
    if (time > 10 && time < 19.40) {
    	d2 = d1; // в рабочее время можно купить билет на сегодня
    } else {
    	d2 = d1 + 1;
    }
    days.slice(0, d2).addClass('disabled');
    days.eq(d1).addClass('today').prepend('<div class="title">сегодня</div>');
    days.eq(d2).addClass('first');
    var index = {};
    this.days = days.slice(d2).each(function(i) {
        index[$(this).attr('data-index', i).attr('data-dmy')] = i;
    });
    this.dmyIndex = index;
},
initTimeline: function() {
    this.makeTabs();
    this.processTabs();
    this.cloneTabs();
},
makeTabs: function() {
    var table = $('<table class="sdt-monthes"></table>');
    var row = $('<tr></tr>').appendTo(table);
    var year = this.csnow.getFullYear();
    var spacer = '<td class="sdt-spacer"></td>';
    for (var i = 0, im = this.monthes.length; i < im; i++) {
        var month = this.monthes[i];
        var cell = $('<th></th>').html('<h6 class="title">' + month.ntitle.capitalize() + '</h6>');
        if (month.year != year) {
            cell.append('<p class="year">' + month.year + '</p>');
            year = month.year;
        }
        row.append(spacer).append(cell).append(spacer);
    }
    this.el.find('.sdt-content').append(table);
},
processTabs: function() {
    var table = this.el.find('.sdt-monthes');
    var twidth = table.width();
    var offsets = table.find('th').map(function() {
        return Math.round($(this).prev().position().left);
    });
    offsets.push(twidth, twidth);
    this.tabs = [];
    for (var i = offsets.length - 2; i--;) {
        var offset = offsets[i];
        this.tabs[i] = {
            single: {left: offset, width: offsets[i + 1] - offset},
            double: {left: offset, width: offsets[i + 2] - offset}
        };
    }
},
cloneTabs: function() {
    var timeline = this.el.find('.sd-timeline');
    $('<div class="sdt-area sdt-left"></div>').data('dindex', 0).data('sindex', 0).appendTo(timeline);
    $('<div class="sdt-area sdt-right"></div>').data('dindex', 10).data('sindex', 10).appendTo(timeline);
    var content = this.el.find('.sdt-content').hide();
    for (var i = 1; i < 11; i++) {
        var tl = this.tabs[i].single.left;
        var fw = this.tabs[i].single.width;
        var hw = Math.round(fw / 2);
        var la = $('<div class="sdt-area"></div>').css({left: tl, width: hw});
        var ra = $('<div class="sdt-area"></div>').css({left: tl + hw, width: fw - hw});
        la.appendTo(content).data('dindex', i - 1).data('sindex', i - 1);
        ra.appendTo(content).data('dindex', Math.min(i, 10)).data('sindex', i - 1);
    }
    content.show();
    this.tlheight = la.height();
},
initScrolling: function() {
    var that = this;
    var areas = this.el.find('.sdt-area');
    areas.mousedown(function(event) {
        if (event.button) return;
        event.preventDefault();
        if (!that.hidden) {
            that.scrollTo(that.getTarget($(this)).pos, that.hidden);
            that.dragging = true;
        }
    });
    areas.mouseup(function() {
        that.dragging = false;
        if (that.hidden) {
            search.map.slideUp();
        } else {
            that.applyPosition();
        }
    });
    if (!browser.touchscreen) {
        areas.mouseover(function() {
            that.hoverTabs(that.getTarget($(this)));
        });
        this.el.find('.sd-timeline').mouseleave(function() {
            that.dragging = false;
            that.phover.hide();
            that.fhover.hide();
        });
    }
    this.phover = this.el.find('.sdt-shover');
    this.fhover = this.el.find('.sdt-fhover');
    this.pscrollbar = this.el.find('.sdt-stab');
    this.fscrollbar = this.el.find('.sdt-ftab');
    this.scrollTo(0);
},
getTarget: function(el) {
    var dp = el.data('dindex');
    if (this.fixed !== undefined) {
        var sp = el.data('sindex'), mp = this.fixed;
        if (sp > mp) return {pos: sp, fix: mp};
        if (sp === mp) return {pos: sp};
    }
    return {pos: dp};
},
hoverTabs: function(target) {
    if (this.hidden) return;
    if (target.fix !== undefined) {
        this.fhover.css(this.tabs[target.fix].single).show();
        this.phover.css(this.tabs[target.pos + 1].single).show();
    } else {
        this.phover.css(this.tabs[target.pos].double).show();
        this.fhover.hide();
    }
    if (this.dragging && target.pos !== this.position) {
        this.scrollTo(target.pos);
    }
},
initGestures: function() {
    var that = this, pdelta = 1;
    this.el.bind('mousewheel DOMMouseScroll', function(event) {
        var e = event.originalEvent, delta;
        if (e.wheelDeltaX) {
            delta = e.wheelDeltaX / -1200;
        } else if (e.axis !== undefined && e.axis === e.HORIZONTAL_AXIS) {
            delta = e.detail;
        }
        if (delta / pdelta < 1 || that.tstab.is(':animated')) {
            pdelta = delta;
        } else if (delta / pdelta > 5) {
            that.scroll((that.position + (delta > 0 ? 1 : -1)).constrain(0, 10));
        }
    });
},
scrollTo: function(np, instant) {
    var that = this;
    var cp = this.position === undefined ? np : this.position;
    var csplit = this.overlay.is(':visible');
    var nsplit = this.fixed !== undefined && np > this.fixed;
    var options = {
        duration: (cp === np || instant) ? 1 : (250 + 50 * Math.abs(cp - np)),
    };
    if (this.fixed !== undefined) {
        var month = this.monthes[this.fixed].el.addClass('fixed');
        var offset = this.mwidth * -this.fixed;
        month.siblings('.fixed').removeClass('fixed').css('left', 0);
        options.step = function(now) {
            month.css('left', Math.max(0, offset - now));
            var split = now < offset;
            if (split !== csplit) {
                that.overlay.toggle(split);
                csplit = split;
            }
        }
    } else if (csplit) {
        this.el.find('.fixed').removeClass('fixed').css('left', 0);
        this.overlay.hide();
    }
    if (nsplit) {
        if (this.fscrollbar.is(':hidden')) {
            var psw = this.pscrollbar.width();
            var psl = this.pscrollbar.position().left;
            var cws = this.tabs[cp].single.width;
            var cwd = this.tabs[cp].double.width;
            var part = Math.round(psw * cws / cwd);
            this.pscrollbar.css({left: psl + part - 10, width: psw - part + 10});
            this.fscrollbar.css({left: psl, width: part + 10}).show();
        }
        this.pscrollbar.animate(this.tabs[np + 1].single, options.duration);
        this.fscrollbar.animate(this.tabs[this.fixed].single, options.duration);
    } else if (csplit) {
        var ptab = this.tabs[np + 1].single;
        var ftab = this.tabs[np].single;
        this.pscrollbar.animate({left: ptab.left - 10, width: ptab.width + 10}, options.duration);
        this.fscrollbar.animate({left: ftab.left, width: ftab.width + 10}, options.duration);
        options.complete = function() {
            that.pscrollbar.css(that.tabs[np].double);
            that.fscrollbar.hide();
        }
    } else {
        this.pscrollbar.stop().animate(this.tabs[np].double, options.duration);
    }
    this.slider.stop().animate({left: this.mwidth * -np}, options);
    this.position = np;
    clearTimeout(this.sftimer);    
},
initDays: function() {
    var that = this;
    var selector = '.sdc-day:not(.disabled)';
    this.mindex = [];
    this.calendar.delegate(selector, 'click', function() {
        that.selectDay($(this));
    });
    if (!browser.touchscreen) {
        this.calendar.delegate(selector, 'mouseover', function() {
            that.hoverDay($(this));
        }).delegate(selector, 'mouseout', function() {
            $(this).removeClass('sdc-hover sdc-hover1 sdc-hover2 sdc-hover3 sdc-hover4 sdc-hover5 sdc-hover6');
        });
    }
    this.selected = [];
    this.backup = [];
    this.limit = 2;
},
setLimit: function(limit) {
    this.limit = limit;
    this.selected = this.backup.concat();
    this.selected.length = Math.min(limit, this.selected.length);
    this.showSelected();
    search.process();    
},
hoverDay: function(day) {
    var sl = this.selected.length;
    if (sl < this.limit) {
        var hsegment = sl + 1;
        var index = Number(day.attr('data-index'));
        for (var i = sl; i--;) {
            if (index < this.selected[i]) hsegment = i + 1;
        }
        day.addClass('sdc-hover sdc-hover'+ hsegment);
    } else {
        day.addClass('sdc-hover sdc-hover1');
    }
},
getDate: function(index) {
    return this.days.eq(index).attr('data-dmy');
},
selectDay: function(day) {
    var index = Number(day.attr('data-index'));
    var same = 0;
    for (var i = this.selected.length; i--;) {
        if (this.selected[i] === index) same++;
    }
    if (same > 1) {
        return false;
    }
    if (this.selected.length < this.limit) {
        this.selected.push(index);
        this.selected.sort(Array.sortInt);
    } else {
        this.selected = [index];
    }
    this.backup = this.selected.concat();
    this.showSelected();
    this.setFixed();
    clearTimeout(this.sftimer);
    if (this.fixed !== undefined && this.fixed > this.position) {
        var that = this;
        this.sftimer = setTimeout(function() {
            that.scrollTo(that.fixed);
        }, 1500);
    } else {
        day.mouseover();
    }
    search.process();
},
setSelected: function(selected) {
    this.selected = selected.concat();
    this.backup = selected.concat();
    this.showSelected();    
},
setFixed: function() {
    if (this.selected.length > 0 && this.selected.length < this.limit) {
        this.fixed = this.days.eq(this.selected.last()).closest('.sdc-month').data('index');
    } else {
        this.fixed = undefined;
    }
},
showSelected: function() {
    this.calendar.find('.sdc-selected').removeClass('sdc-selected sdc-selected1 sdc-selected2 sdc-selected3 sdc-selected4 sdc-selected5 sdc-selected6');
    for (var i = this.selected.length; i--;) {
        this.days.eq(this.selected[i]).addClass('sdc-selected sdc-selected' + (i + 1));
    }
    this.showPreview();
},
showPreview: function() {
    var context = this.el.find('.sdt-selected').html('');
    var items = [];
    for (var i = 0, im = this.selected.length; i < im; i++) {
        var index = this.selected[i];
        var item = {};
        var date = this.days.eq(index).find('.date').text();
        item.el = $('<div class="sdt-day"></div>').html(date).appendTo(context),
        item.width = item.el.outerWidth();
        var mindex = this.days.eq(index).closest('.sdc-month').data('index');
        item.minleft = this.tabs[mindex].single.left;
        item.maxleft = item.minleft + this.tabs[mindex].single.width - item.width;
        item.left = item.minleft + Math.round((Number(date) - 1) / (this.monthes[mindex].length - 1) * (item.maxleft - item.minleft));
        items.push(item);
        item.el.addClass('sdt-segment' + (i + 1));
    }
    if (items.length > 1) {
        var im = items.length, counter = 0;
        do { // раздвигаем перекрывающиеся даты
            var lap = false;
            for (var i = im; i--;) {
                var dc = items[i], dl = items[i - 1], dr = items[i + 1];
                var lapl = dl ? Math.max(0, dl.left + dl.width - dc.left) : 0;
                var lapr = dr ? Math.max(0, dc.left + dc.width - dr.left) : 0;
                if (lapl || lapr) {
                    var shift = Math.random() > lapl / (lapl + lapr) ? -1 : 1; // сдвигаем в сторону меньшего перекрытия
                    dc.left = (dc.left + shift).constrain(dc.minleft, dc.maxleft);
                    lap = true;
                }
            }
            counter++;
        } while(lap && counter < 100)
    }
    for (var i = items.length; i--;) {
        items[i].el.css('left', items[i].left);
    }
},
toggleHidden: function(mode) {
    this.el.toggleClass('sd-hidden', mode);
    this.hidden = mode;
},
applyPosition: function() {
    if (search.map.cachedSegments) {
        search.map.updatePrices(search.map.cachedSegments, true);
        if (search.map.pricesMode) {
            search.map.loadPrices();
        }
    }
}
};
