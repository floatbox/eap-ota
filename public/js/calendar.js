/* Dates */
Date.prototype.clone = function() {
	return new Date(this.getTime());
}
Date.prototype.shift = function(days) {
	this.setDate(this.getDate() + days);
	return this;
}
Date.prototype.dayoff = function() {
	var dow = this.getDay();
	return (dow == 0 || dow == 6);
}
Date.parseAmadeus = function(str) {
	var d = parseInt(str.substring(0,2), 10);
	var m = parseInt(str.substring(2,4), 10) - 1;
	var y = parseInt(str.substring(4,6), 10) + 2000;
	return new Date(y, m, d);
}

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
		var s = this.el.text();
		if (s.length == 1) s = "0" + s; 
		return s + this.el.parent("ul").attr("data-month");
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
}

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
	var btimer, self_bring = function() {
		self.bring();
	};
	this.dates = $(".dates", this.el).scroll(function() {
		clearTimeout(btimer);
		btimer = setTimeout(self_bring, 500);
	}).delegate("li:not(.past)", "click", function() {
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
	}).delegate("li:not(.past)", "mouseover", function() {
		if (self.dpt.el || self.ret.el) self.highlight(this);
	}).mouseout(function() {
		self.highlight();
	});
	this.lastst = this.dates.scrollTop();
	$("li", this.dates).each(function() {
		$(this).data("index", counter);
		days[counter++] = this;
	});
	this.days = days;
	this.rowHeight = $(this.days[0]).outerHeight();
	$(".panel-reset", this.el).click(function() {
		self.dpt.select(undefined, true);
		self.ret.select(undefined, true);
		self.update();
	});
	var cancel = function(event) {
		event.preventDefault();
	}
	$(".scrollfw").click(function() {
		self.scroll(self.lastst + self.rowHeight);
	}).mousedown(cancel);
	$(".scrollbw").click(function(event) {
		self.scroll(self.lastst - self.rowHeight);
	}).mousedown(cancel);
},
build: function() {
	var today = new Date();
	var offset = (today.getDay() || 7) - 1;
	var date = today.clone().shift(offset);
	var last = today.clone();
	last.setMonth(last.getMonth() + 6);
	var month = $("<ul>").addClass("month");
	var day = $("<li>");
	if (date.dayoff()) day.addClass("dayoff");
},
nearest: function(el) {
	if (this.dpt.el && this.ret.el) {
		var index = $(el).data("index");
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
	$({st: curst}).animate({st : newst}, {
		duration: 100 + Math.abs(curst - newst) * 2,
		step: function() {
			el.scrollTop(this.st);
		},
		complete: function() {
			el.scrollTop(newst);
			self.lastst = el.scrollTop();
		}
	});
}
}







/* Constrain */
Number.prototype.constrain = function(min, max) {
	var n = this.valueOf();
	return (n < min) ? min : ((n > max) ? max : n);
}

/* Search */
function loadResults() {
	var c = app.calendar;
	var date1 = c.dpt && c.date(c.dpt);
	var date2 = c.ret && c.date(c.ret);
	var from = $("#search\\.from").val();
	var to = $("#search\\.to").val();
	if (date1 && date2) {
		$("#offers\\.transcript").removeClass("g-none");
		$("#offers\\.loader").removeClass("g-none");
		$.get("/pricer/", {
			search: {
				"search_type": "travel",
				"debug": 0,
				"from": from,
				"to": to, 
				"rt": 1,
				"date1": date1,
				"date2": date2,
				"adults": 1,
				"children": 0,
				"nonstop": 0,
				"day_interval": 1
			}
		}, function(s) {
			$("#offers\\.loader").addClass("g-none");
			$("#offers").html(s).removeClass("g-none");
		});
	}
}
