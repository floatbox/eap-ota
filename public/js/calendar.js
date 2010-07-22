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
}
app.CalendarDate.prototype = {
val: function(date) {
	if (arguments.length) {
	} else if (this.el) {
		var parent = this.el.parent("ul");
		var d = this.el.children("span").text();
		var m = parent.data("month") + 1;
		var y = parent.data("year") % 100;
		return [d.length == 1 ? '0' : '', d, m > 10 ? '0' : '0', m, y].join('');
	} else {
		return undefined;
	}
},
select: function(el, stealth) {
    if (this.el) this.el.removeClass(this.type);
    this.el = el && $(el).addClass(this.type);
    this.index = el ? this.el.data("index") : undefined;
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
	var counter = 0, days = [];
	this.initDates();
	this.initScroller();
	$('.panel-reset', this.el).click(function() {
		self.dpt.select(undefined, true);
		self.ret.select(undefined, true);
		self.update();
	});
},
initDates: function() {
	this.dates = $('.dates', this.el).hide().html('');
	var today = new Date();
	var cd = today.clone().shift(1 - (today.getDay() || 7));
	var ld = today.clone();
	ld.setMonth(ld.getMonth() + 6);
	var tt = today.getTime();
	var ct = cd.getTime();
	var lt = ld.getTime();
	var et = ld.shift(15 - (ld.getDay() || 7)).getTime();
	var month = undefined, counter = 0, days = [];
	while (ct < et) {
		var date = cd.getDate();
		if (!month || date == 1) {
			month = $('<ul>').addClass('month').appendTo(this.dates);
			month.data('month', cd.getMonth()).data('year', cd.getFullYear());
		}
		var day = $("<li>").data('index', counter);
		if (ct < tt || ct > lt) {
			day.addClass('inactive');
		}
		var label = $('<span>').text(date);
		if (cd.dayoff()) {
			label.addClass('dayoff');
		}
		month.append(day.append(label));
		days[counter++] = day;
		ct = cd.shift(1).getTime();
	}
	$('.month:odd', this.dates).addClass('odd');
	var self = this;
	this.days = days;
	this.dates.show().delegate('li:not(.inactive)', 'click', function() {
		if (self.dpt.el && self.ret.el) {
			self.nearest(this).select(this);
		} else if (self.dpt.el) {
			var n = $(this).data("index");
			if (n < self.dpt.index) {
				self.ret.select(self.days[self.dpt.index], true);
				self.dpt.select(this);
			} else {
				self.ret.select(this);
			}
		} else {
			self.dpt.select(this);
		}
	}).delegate('li:not(.inactive)', 'mouseover', function() {
		if (self.dpt.el || self.ret.el) self.highlight(this);
	}).mouseout(function() {
		self.highlight();
	});
},
initScroller: function() {
	var factor = 1.5;
	var scroller = $('.scroller', this.el).width(Math.round(this.days.length * factor));
	var list = $('.timeline', scroller).hide().html(''), year;
	$('.month', this.dates).each(function() {
		var m = $(this).data('month');
		var y = $(this).data('year');
		var w = Math.round(Date.daysInMonth(m, y) * factor);
		var month = $('<dt>').addClass('month').width(w);
		month.text(app.constant.SMN[m]).appendTo(list);
		year = y;
	});
	$('<dd>').text(year).appendTo(list);
	var offset = 1 - parseInt(this.days[0].children('span').text(), 10);
	list.css('left', Math.round(offset * factor)).show();
	var self = this, cancel = function(event) {
		event.preventDefault();
	};
	this.rowHeight = $(this.days[0]).outerHeight();
	this.lastst = this.dates.scrollTop();
	$('.scrollfw').click(function() {
		self.scroll(self.lastst + self.rowHeight);
	}).mousedown(cancel);
	$('.scrollbw').click(function(event) {
		self.scroll(self.lastst - self.rowHeight);
	}).mousedown(cancel);
	var btimer, self_bring = function() {
		self.bring();
	};
	var scrollbar = $('.scrollbar', this.el).width(42 * factor);
	var sbfactor = 7 * factor / self.rowHeight;
	var sblmax = scroller.width() - scrollbar.width();
	this.dates.scroll(function() {
		clearTimeout(btimer);
		if (self.dragfrom === undefined) {
			scrollbar.css('left', Math.round($(this).scrollTop() * sbfactor));
			btimer = setTimeout(self_bring, 500);
		}
	});
	scroller.click(function(event) {
		this.dragfrom = undefined;
		var w = scrollbar.width();
		var x = event.pageX - $(this).offset().left - w / 2;
		self.scroll(Math.round(x.constrain(0, sblmax) / (factor * 7)) * self.rowHeight);
	}).mousedown(function(event) {
		event.preventDefault();
		var sborigin = scrollbar.position().left;
		var x = event.pageX - $(this).offset().left - sborigin;
		if (x > 0 && x < scrollbar.width()) {
			self.dragfrom = event.pageX;
			var drag = function(event) {
				var dx = event.pageX - self.dragfrom;
				var sbl =  (sborigin + dx).constrain(0, sblmax);
				scrollbar.css('left', sbl);
				self.dates.scrollTop(sbl / sbfactor);
			};
			$(window).mousemove(drag).one('mouseup', function() {
				$(window).unbind('mousemove', drag);
				self.dragfrom = undefined;
				self.bring();
			});
		}
	});	
},
nearest: function(el) {
	if (this.dpt.el && this.ret.el) {
		var index = $(el).data('index');
		var dd = Math.abs(this.dpt.index - index);
		var dr = Math.abs(this.ret.index - index);
		return (dd < dr) ? this.dpt : this.ret;	
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
    app.search.change();
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
bring: function() {
    var curst = this.dates.scrollTop();
    var extst = curst + 15 * (curst - this.lastst).constrain(-1, 1);
    var newst = Math.round(extst / this.rowHeight) * this.rowHeight;
    this.scroll(newst);
},
scroll: function(newst) {
	var self = this, el = this.dates, curst = el.scrollTop();
	if (curst == newst) {
		self.lastst = curst;
		return;
	}
	$({st: curst}).animate({st : newst}, {
		duration: 150 + Math.round(Math.abs(curst - newst) / 3),
		step: function() {
			el.scrollTop(this.st);
		},
		complete: function() {
			el.scrollTop(newst);
			self.lastst = el.scrollTop();
		}
	});
}
};

/* Constrain */
Number.prototype.constrain = function(min, max) {
	var n = this.valueOf();
	return (n < min) ? min : ((n > max) ? max : n);
};
