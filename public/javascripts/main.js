/* Old namespace */
window.app = {};

/* Constants */
var constants = {
    weekdays: ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'],
    monthes: {
        nomimative: ['январь', 'февраль', 'март', 'апрель', 'май', 'июнь', 'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'],
        genitive: ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'],
        short: ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
    },
    numbers: {
        nomimative: ['ноль', 'один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять', 'десять', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать', 'двадцать'],
        collective: ['ноль', 'один', 'двое', 'трое', 'четверо', 'пятеро', 'шестеро', 'семеро', 'восьмеро'],
        ordinaldat: ['первому', 'второму', 'третьему', 'четвертому', 'пятому', 'шестому', 'седьмому', 'восьмому']
    },
    countries: ['','abjasia','ad','ae','af','ag','ai','al','am','an','ao','aq','ar','as','at','au','aw','ax','az','ba','bb','bd','be','bf','bg','bh','bi','bj','bl','bm','bn','bo','br','bs','bt','bv','bw','by','bz','ca','cc','cd','cf','cg','ch','ci','ck','cl','cm','cn','co','cr','cu','cv','cx','cy','cz','de','dj','dk','dm','do','dz','ea_m','ea_s','ec','ee','eg','eh','er','es','et','eu','fi','fj','fk','fm','fo','fr','ga','gb','gd','ge','gf','gg','gh','gi','gl','gm','gn','gp','gq','gr','gs','gt','gu','gw','gy','hk','hm','hn','hr','ht','hu','ic','id','ie','il','im','in','io','iq','ir','is','it','je','jm','jo','jp','ke','kg','kh','ki','km','kn','kosovo','kp','kr','kw','ky','kz','la','lb','lc','li','lk','lr','ls','lt','lu','lv','ly','ma','mc','md','me','mf','mg','mh','mk','ml','mm','mn','mo','mp','mq','mr','ms','mt','mu','mv','mw','mx','my','mz','na','nc','ne','nf','ng','ni','nl','no','np','nr','nu','nz','om','pa','pe','pf','pg','ph','pk','pl','pm','pn','pr','ps','pt','pw','py','qa','re','ro','rs','ru','rw','sa','sb','sc','sd','se','sg','sh','si','sj','sk','sl','sm','sn','so','south_ossetia','sr','st','sv','sy','sz','tc','td','tf','tg','th','tj','tk','tl','tm','tn','to','tr','tt','tv','tw','tz','ua','ug','um','us','uy','uz','va','vc','ve','vg','vi','vn','vu','wf','ws','ye','yt','za','zm','zw']
};

/* Function prototype */
Function.prototype.extend = function(p) {
    var f = function(){};
    f.prototype = p.prototype;
    this.prototype = new f();
    this.prototype.constructor = this;
    this.superclass = p.prototype;
};

/* Array prototype */
Array.prototype.last = function() {
    return this[this.length - 1];
};
Array.prototype.sortInt = function() {
    this.sort(function(a, b) {
        return (a - b);
    });
    return this;
};
Array.prototype.compact = function() {
    var result = [];
    for (var i = 0, im = this.length; i < im; i++) {
        if (this[i] !== undefined) result.push(this[i]);
    }
    return result;
};
Array.prototype.enumeration = function(cnj) {
    var str = this.slice(0, this.length - 1).join(', ');
    if (str) str += cnj || ' и ';
    str += this.last();
    return str;
};

/* Number prototype */
Number.prototype.constrain = function(min, max) {
    var n = this.valueOf();
    return (n < min) ? min : ((n > max) ? max : n);
};
Number.prototype.inflect = function(w1, w2, w3, complex) {
	var nn = this % 100, n = nn % 10;
	var w = n > 4 || n === 0 || nn - n === 10 ? w3 : (n === 1 ? w1 : w2);
	return complex === false ? w : (this.toString() + '&nbsp;' + w);
};

/* String prototype */
String.prototype.supplant = function(o) { // http://sreznikov.blogspot.com/2010/01/supplant.html
    return this.replace(/{([^{}]*)}/g,
        function(a, b) {
            var r = o[b];
            return typeof r === 'string' || typeof r === 'number' ? r : a;
        }
    );
};

/* Date prototype */
Date.prototype.clone = function() {
    return new Date(this.getTime());
};
Date.prototype.shiftDays = function(d) {
    this.setDate(this.getDate() + d);
    return this;
};
Date.prototype.shiftMonthes = function(m) {
    this.setMonth(this.getMonth() + m);
    return this;
};
Date.prototype.dayoff = function() {
    var dow = this.getDay();
    return (dow == 0 || dow == 6);
};
Date.prototype.toAmadeus = function() {
    var d = this.getDate();
    var m = this.getMonth() + 1;
    var y = this.getFullYear().toString().substring(2);
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

/* Jquery UI emulation */
$.ui = {
keyCode: {
	ALT: 18,
	BACKSPACE: 8,
	CAPS_LOCK: 20,
	COMMA: 188,
	COMMAND: 91,
	COMMAND_LEFT: 91, // COMMAND
	COMMAND_RIGHT: 93,
	CONTROL: 17,
	DELETE: 46,
	DOWN: 40,
	END: 35,
	ENTER: 13,
	ESCAPE: 27,
	HOME: 36,
	INSERT: 45,
	LEFT: 37,
	MENU: 93, // COMMAND_RIGHT
	NUMPAD_ADD: 107,
	NUMPAD_DECIMAL: 110,
	NUMPAD_DIVIDE: 111,
	NUMPAD_ENTER: 108,
	NUMPAD_MULTIPLY: 106,
	NUMPAD_SUBTRACT: 109,
	PAGE_DOWN: 34,
	PAGE_UP: 33,
	PERIOD: 190,
	RIGHT: 39,
	SHIFT: 16,
	SPACE: 32,
	TAB: 9,
	UP: 38,
	WINDOWS: 91 // COMMAND
}
};
$.extend($.easing, {
	def: 'easeOutQuad',
	easeInOutQuart: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
		return -c/2 * ((t-=2)*t*t*t - 2) + b;
	}
});

/* Animated window scrolling */
$.animateScrollTop = function(st, complete) {
    var w = $(window);
    var cst = w.scrollTop();
    var options = {
        duration: 250 + Math.round(Math.abs(st - cst) / 5),
        step: function() {
            w.scrollTop(this.st);
        }
    };
    if (complete) {
        options.complete = complete;
    }
    $({st: cst}).animate({
        st: st
    }, options);
};

/* Fixed blocks */
var fixedBlocks = {
init: function() {
    var that = this;
    if (browser.search(/ipad|iphone|msie6|msie7|opera/) !== -1) {
        this.update = function() {};
        this.toggle = function() {};
    } else {
        this.canvas = $(window).scroll(function() {
            that.toggle();
        });
        this.pheader = $('#header');
        this.rheader = $('#results-header');
        this.sdefine = $('#search-define');
        this.update();
    }
},
update: function(forced) {
    var rh = this.rheader.height();
    var ph = this.rheader.closest('.placeholder').height(rh || 'auto');
    this.top2 = Math.ceil(this.sdefine.offset().top + this.sdefine.height());
    this.top3 = rh ? Math.ceil(ph.offset().top + rh - results.title.outerHeight() - 60) : 2000;
    this.top1 = this.top2 - this.pheader.height();
    this.toggle(forced);
},
toggle: function(forced) {
    var section = 0;
    var st = this.canvas.scrollTop();
    if (st > this.top3) {
        section = 3;
    } else if (st > this.top2) {
        section = 2;
    } else if (st > this.top1) {
        section = 1;
    }
    if ((forced || section !== this.section) && !this.disabled) {
        this.pheader.css({
            top: section === 0 ? 0 : this.top1,
            position: section === 0 ? 'fixed' : 'absolute'
        });
        this.rheader.toggleClass('fixed', section > 1);
        this.rheader.find('.rfhide').toggle(section > 2);
        if (results.filters.el.is(':visible')) {
            var hidden = results.filters.el.hasClass('hidden');
            if (section > 2 && !hidden) {
                results.filters.hide();
            } else if (section < 3 && hidden) {
                results.filters.show();
            }
        }
        this.section = section;
    }
}
};

/* Console */
window.log = (document.location.host).indexOf('team') > -1 ? (window.console && console.log || alert) : $.noop;

/* Preload images */
function preload() {
    for (var i = arguments.length; i--;) {
        var img = new Image();
        img.src = arguments[i];
    }
}

/* Detect browser */
var browser = (function() {
    var os = navigator.platform.toLowerCase().match(/mac|win|linux|ipad|iphone/);
    var agent = navigator.userAgent.toLowerCase().match(/safari|opera|msie \d|firefox|chrome/);
    agent = agent && agent[0].replace(/\s/, '');
    var browser = os && agent ? os + " " + agent : undefined;
    if (agent == 'msie6') try {document.execCommand('BackgroundImageCache', false, true);} catch(e) {}
    if (browser) $(document.documentElement).addClass(browser);
    return browser;
})();
