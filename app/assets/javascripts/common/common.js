/* Prototypes */
with (Number) {
prototype.decline = function(w1, w2, w3, complex) {
    var nn = this.valueOf() % 100, n = nn % 10;
	var w = n > 4 || n === 0 || nn - n === 10 ? w3 : (n === 1 ? w1 : w2);
	return complex === false ? w : (this.toString() + ' ' + w);
};
prototype.constrain = function(min, max) {
    var n = this.valueOf();
	return (n < min) ? min : ((n > max) ? max : n);
};
prototype.separate = function() {
    var s = this.toString();
    for (var i = s.length / 3; i > 1; i--) {
        s = s.replace(/(\d+)(\d{3})/, '$1<span class="thousand">$2</span>');
    }
    return s;
};}

with (Array) {
prototype.last = function() {
	return this[this.length - 1];
};
prototype.except = function(value) {
	return $.grep(this, function(item) {
		return item !== value;
	});
};
prototype.toIndex = function() {
    var index = {};
    for (var i = this.length; i--;) {
        index[this[i]] = true;
    }
    return index;
};
prototype.enumeration = function(c) {
	var pa = this.slice(0, this.length - 1);
	var ps = pa.length ? (pa.join(', ') + (c || ' и ')) : '';
	return ps + this.last();
};}
Array.sortInt = function(a, b) {
    return a - b;
};

with (String) {
prototype.contains = function(str) {
	return (this.indexOf(str) !== -1);
};
prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.substring(1);
};
prototype.nowrap = function() {
    return this.replace(/ /g, '&nbsp;');
};
String.prototype.absorb = function(data) {
    var h = typeof data === 'object';
    var parts = h ? data : arguments;
    return this.replace(/\{(\w+)\}/g, function(s, key) {
        return parts[h ? key : Number(key)];
    });
};}

with (Date) {
prototype.clone = function() {
    return new Date(this.getTime());
};
prototype.shift = function(d) {
    this.setDate(this.getDate() + d);
    return this;
};
prototype.human = function(year) {
    var parts = [this.getDate(), local.date.gmonthes[this.getMonth()]];
    if (year) parts[2] = this.getFullYear();
    return parts.join(' ');
};
prototype.dow = function() {
    var d = this.getDay();
    return d === 0 ? 6 : (d - 1);
};
prototype.DMY = function() {
    var d = this.getDate();
    var m = this.getMonth() + 1;
    var y = this.getFullYear().toString().substring(2);
    return [d < 10 ? '0' : '', d, m < 10 ? '0' : '', m, y].join('');
};
prototype.age = function(d) {
    var dy = this.getFullYear() - d.getFullYear();
    if (this.getMonth() * 100 + this.getDate() < d.getMonth() * 100 + d.getDate()) dy--;
    return dy;
};}
Date.parseDMY = function(str) {
    var d = parseInt(str.substring(0,2), 10);
    var m = parseInt(str.substring(2,4), 10) - 1;
    var y = parseInt(str.substring(4,6), 10) + 2000;
    return new Date(y, m, d);
};

/* Fake console */
if (typeof console === 'undefined') {
    console = {log: $.noop};
}

/* Preloading */
function preloadImages() {
    for (var i = arguments.length; i--;) {
        var img = new Image();
        img.src = arguments[i];
    }
}

/* Window shortcut */
var $w = $(window);

/* Animated scrolling */
$.fn.extend({
smoothScrollTo: function(pos, dur) {
    var el = this, cur = el.scrollTop();
    if (typeof dur !== 'number') {
        var dist = Math.abs(pos - cur);
        dur = dur ? dur(dist) : (Math.round(dist / 5) + 250);
    }
    return this.queue(function() {
        $({pos: cur}).animate({pos: pos}, {
            duration: dur,
            complete: function() {el.scrollTop(pos).dequeue();},
            step: function() {el.scrollTop(this.pos);}
        });
    });
}
});

/* Cookies */
var Cookie = function(name, value, date) {
	if (arguments.length > 1) {
		var format = '{0}={1};{2}path=/';
		var exp = (value !== undefined) ? (date ? date.toGMTString() : '') : 'Thu, 01-Jan-1970 00:00:01 GMT';
		document.cookie = format.absorb(name, encodeURIComponent(value), exp && ('expires=' + exp + ';'));
		return value;
	} else {
		var pattern = new RegExp('(?:^' + name + '|; ?' + name + ')=([^;]*)');
		var result = pattern.exec(document.cookie);
		return (result) ? decodeURIComponent(result[1]) : undefined;
	}
};

/* Browser detection */
var browser = (function() {
	var data = {}, signs = [], bn, bv, bp;
	if (bp = navigator.platform.toLowerCase().match(/mac|win|linux|ipad|iphone/)) {
		signs.push(data.platform = bp[0]);
	}
	var ua = navigator.userAgent.toLowerCase();
	if (bn = ua.match(/safari|opera|msie|firefox|chrome/)) {
		signs.push(data.name = bn[0]);
		if (bv = ua.match(/(?:msie|firefox|chrome|version)[ \/]([\d.]+)/)) {
			data.version = parseFloat(bv[1]);
			signs.push(data.name + Math.floor(data.version));
		}
	}
	var $d = $(document.documentElement);
	for (var i = 0; i < signs.length; i++) {
		data[signs[i]] = true;
		$d.addClass(signs[i]);
	}
	data.touchscreen = 'ontouchstart' in window;
	data.ios = data.iphone;
	return data;
})();

/* Array prototype */
Array.prototype.unique = function() {
    var result = [], index = {};
    for (var i = 0, im = this.length; i < im; i++) {
        var value = this[i];
        if (index[value] === undefined) {
            result.push(value);
            index[value] = true;
        }
    }
    return result;
};
