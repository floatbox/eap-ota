/* Cache */
search.locationsCache = {};

/* Locations */
search.locations = {
init: function() {
    this.parent = search;
    this.segments = [];
    this.items = [];
    var Location = this.parent.Location;
    var that = this;
    this.el = $('#search-locations');
    this.el.find('.sl-segment').each(function(i) {
        var el = $(this);
        var segment = {
            el: el,
            dpt: new Location(el.find('.dpt'), 'dpt'),
            arv: new Location(el.find('.arv'), 'arv'),
            icon: el.find('.sl-icon')
        };
        that.items.push(segment.dpt, segment.arv);
        that.segments[i] = segment;
    });
    for (var i = this.items.length - 1; i--;) {
        this.items[i].next = this.items[i + 1];
        this.items[i + 1].prev = this.items[i];
    }
    this.remControls = this.el.find('.sl-remove').click(function() {
        that.removeSegment(parseInt($(this).closest('.sl-segment').attr('data-segment'), 10));
    });
    this.addControls = this.el.find('.sl-add').click(function() {
        that.addSegment();
    });
},
toggleSegments: function(used) {
    this.used = used;
    for (var i = this.segments.length; i--;) {
        var active = i < used, segment = this.segments[i];
        segment.el.toggle(active);
        segment.dpt.field.prop('disabled', !active);
        segment.arv.field.prop('disabled', !active);        
    }
    var rt = search.mode.selected === 'rt';
    search.dates.setLimit(rt ? 2 : used);
    search.dates.calendar.toggleClass('sdc-rtmode', rt);
    this.segments[0].icon.toggleClass('sl-return', rt);
    this.addControls.hide();
    this.remControls.show();
    if (used < this.segments.length) {
        this.remControls.eq(used - 2).hide();
        this.addControls.eq(used - 2).show();
    }
},
countUsed: function() {
    for (var i = this.segments.length - 1; i > 1; i--) {
        var dpt = this.segments[i].dpt.value;
        var arv = this.segments[i].arv.value;
        if (dpt || arv) {
            return i + 1;
        }
    }
    return 2;
},
addSegment: function() {
    this.toggleSegments(this.used + 1);
    this.focusEmpty();
},
removeSegment: function(index) {
    var segment = this.segments[2];
    for (var i = index - 1; i < this.used - 1; i++) {
        var next = this.segments[i + 1];
        this.segments[i].dpt.set(next.dpt.selected || next.dpt.value);
        this.segments[i].arv.set(next.arv.selected || next.arv.value);
    }
    this.segments[this.used - 1].dpt.set('');
    this.segments[this.used - 1].arv.set('');
    this.toggleSegments(this.used - 1);
    this.focusEmpty();
},
focusEmpty: function() {
    for (var i = 0, im = this.items.length; i < im; i++) {
        var item = this.items[i];
        if (!item.value && !item.field.prop('disabled')) {
            item.field.select();
            item.clonePrev();
            return item;
        }
    }
},
toggleLeave: function(leave) {
    this.segments[0].icon.toggleClass('sl-leave', Boolean(leave));
}
};

/* Location constructor */
search.Location = function(selector, type) {
    this.el = $(selector);
    this.type = type;
    this.init();
    return this;
};
search.Location.prototype = {
init: function() {
    var that = this;
    this.field = this.el.find('input');
    this.value = this.field.val('').val();
    this.label = this.el.find('label').toggle(this.value === '');
    this.sign = $('<span class="sl-sign"></span>').appendTo(this.el);
    this.field.data('location', this);
    this.field.bind('keyup propertychange input', function() {
        if (this.value !== that.value) {
            that.change();
        }
    }).bind('keydown', function(event) {
        that.hotkey(event);
    }).focus(function() {
        that.focus();
    }).blur(function() {
        that.blur();
    });
    this.field.mouseup(false);
    this.variants = [];
    this.$load = function() {
    	that.load();
    };    
    this.initDropdown();
    if (this.value.length !== 0) {
        this.change();
    }
},
focus: function() {
    this.active = true;
    this.value = this.field.val();
    if (this.value !== '') {
        this.label.hide();
    	this.field.select();
       	this.toggleVariants();
    }
},
blur: function() {
    this.active = false;
    this.dropdown.hide();
    this.label.toggle(this.value === '');
},
initDropdown: function() {
    this.dropdown = $('<div class="sl-dropdown"></div>').appendTo(this.el);
    this.ddlist = $('<ul class="sld-list"></ul>').appendTo(this.dropdown);
    this.ddhint = $('<p class="sld-hint"></p>').appendTo(this.dropdown);
    var that = this;
    this.ddlist.delegate('.sld-item:not(.sld-preferred)', 'mousemove', function() {
	    that.prefer(parseInt($(this).attr('data-index'), 10));
    });
    this.ddlist.delegate('.sld-item', 'click', function() {
	    var index = parseInt($(this).attr('data-index'), 10);
	    that.select(that.variants[index]);
	    that.focusNext();
    });
    this.ddlist.mousedown(function(event) {
        if (!event.button) {
            event.preventDefault();
        }
    });
},
change: function(selected) {
    var value = this.field.val();
    if (value !== this.value) {
        clearTimeout(this.timer);
        this.label.toggle(value === '');
        this.value = value;
        if (!selected && this.selected) {
            this.select();
        }
        if (value !== '') {
            var cached = search.locationsCache[value];
            if (cached) {
                this.restore(cached, true);
            } else {
                this.filter();
                this.timer = setTimeout(this.$load, 300);
            }
        } else {
        	this.variants = [];
            this.dropdown.hide();
        }
        if (this.request) {
            this.request.abort();
        }
    }
},
load: function() {
    var that = this;
    this.request = $.ajax({
        method: 'GET',
        url: '/complete.json',
        data: {
            val: this.value,
            pos: this.value.length,
            limit: 8
        },
        success: function(result) {
            that.update(result.query, result.data);
        },
        timeout: 10000
    });
},
update: function(value, variants) {
    var list = $('<ul></ul>');
    var sample = value.toLowerCase();
    var template = '{0} <span class="larea">{1}</span>';
    for (var i = 0, im = variants.length; i < im; i++) {
        var v = variants[i];
        var el = $('<li class="sld-item"></li>').html(template.absorb(v.name, v.area));
        var sign = this.getSign(v);
        if (sign) {
            el.append(sign);
        }
        el.attr('data-index', i).appendTo(list);
        v.sample = v.name.toLowerCase();
        v.special = v.sample.indexOf(sample) === -1;
    }
    var data = {
    	content: list.html(),
    	variants: variants
    };
    search.locationsCache[value] = data;
    this.restore(data);
},
restore: function(data, cached) {
	this.items = this.ddlist.html(data.content).children();
	this.variants = data.variants;
	this.preferred = undefined;
	if (this.variants.length !== 0) {
    	this.prefer(0);
    }
	if (this.variants.length === 1 && !this.selected) {
        this.dropdown.hide();
        var that = this;
        var variant = this.variants[0];
        if (cached) {
            this.timer = setTimeout(function() {
                that.select(variant);
            }, 500);    
        } else {
            this.select(variant);
        }
	} else {
        this.toggleVariants(this.active);
	}
},
getSign: function(variant) {
    var flag = variant.type === 'country' ? search.flags[variant.iata] : undefined;
    if (flag !== undefined) {
    	return '<span class="lflag" style="background-position: 0 -' + flag + 'px;"></span>';
    } else if (variant.iata) {
    	return '<span class="liata">' + variant.iata + '</span>';
    } else {
        return '';
    }
},
filter: function() {
    var cv = this.variants, nv = [];
    var sample = this.value.toLowerCase();
    for (var i = this.variants.length; i--;) {
        var variant = this.variants[i];
        if (variant.sample.indexOf(sample) === -1) {
            this.items.eq(i).addClass('sld-improper');
        }
    }
},
toggleVariants: function(stealth) {
    this.dropdown.toggle(!this.selected && stealth !== false && this.variants.length !== 0);
},
prefer: function(index, scroll) {
	if (this.preferred) this.preferred.removeClass('sld-preferred');
   	this.preferred = this.items.eq(index).addClass('sld-preferred');
   	this.ddhint.html(this.variants[index].hint);
   	if (scroll) {
        var st = this.ddlist.scrollTop();
        var ot = this.preferred.position().top + st;
        if (ot < st) {
            this.ddlist.scrollTop(ot === 1 ? 0 : ot);
        } else {
            var lh = this.ddlist.height();    
            var ph = this.preferred.outerHeight();
            if (ot + ph > st + lh) {
                this.ddlist.scrollTop(ot + ph - lh - 1);
            }
        }
    }
},
pass: function(dir) {
  	var index = dir + (this.preferred ? Number(this.preferred.attr('data-index')) : -1);
	if (index > this.items.length - 1) index = 0;
	if (index < 0) index = this.items.length - 1;
	this.prefer(index, true);
},
select: function(variant) {
    this.dropdown.hide();    
    if (this.selected = variant) {
        var sign = this.getSign(variant);
        this.sign.html(sign).toggle(sign !== '');
        this.field.val(variant.name);
        this.change(true);
        this.focusNext();
    } else {
        this.sign.hide();
    }
    search.process();
},
hotkey: function(event) {
	var key = event.which;
	if (key == 63232) key = 38;
	if (key == 63233) key = 40;
    switch (key) {
		case 38:
            event.preventDefault();
            this.pass(-1);
            break;
		case 40:
            event.preventDefault();
            if (this.dropdown.is(':hidden') && this.variants.length !== 0 && !this.selected) {
                this.dropdown.show();
            }
            this.pass(1);
            break;
        case 9:
            if (this.preferred) {
                event.preventDefault();
                this.confirm();
            }
            break;
        case 13:
            event.preventDefault();
            this.confirm();
            break;
		case 27: 
            this.field.blur();
            break;
    }
},
confirm: function() {
    if (this.preferred) {
        var index = parseInt(this.preferred.attr('data-index'), 10);
        var selected = this.variants[index];
        this.variants = [selected];
        this.select(selected);
    }
},
set: function(value) {
    if (typeof value === 'string') {
        delete this.value;
        this.field.val(value);
        this.select();
        this.change();
    } else {    
        if (!value.sample) value.sample = value.name.toLowerCase();
        this.variants = [value];
        this.select(value);
    }
    if (!this.active) {
        this.blur();
    }
},
clonePrev: function() {
    if (this.type === 'dpt' && !this.selected) {
        var prev = this.prev;
        if (prev && prev.selected) {
            this.set(prev.selected || prev.value);
        }
    }
},
focusNext: function() {
    if (this.next && !this.next.field.prop('disabled')) {
        this.next.field.select();
        this.next.clonePrev();
    } else {
        this.field.blur();
    }
}
};

/* Flags sprite */
search.flags = {
	'ABKHAZIA': 0, 'AD': 9, 'AE': 18, 'AF': 27, 'AG': 36, 'AI': 45, 'AL': 54, 'AM': 63, 'AN': 72, 'AO': 81, 'AQ': 90, 'AR': 99, 'AS': 108, 'AT': 117, 
	'AU': 126, 'AW': 135, 'AX': 144, 'AZ': 153, 'BA': 162, 'BB': 171, 'BD': 180, 'BE': 189, 'BF': 198, 'BG': 207, 'BH': 216, 'BI': 225, 'BJ': 234, 
	'BL': 243, 'BM': 252, 'BN': 261, 'BO': 270, 'BR': 279, 'BS': 288, 'BT': 297, 'BV': 306, 'BW': 315, 'BY': 324, 'BZ': 333, 'CA': 342, 'CC': 351, 
	'CD': 360, 'CF': 369, 'CG': 378, 'CH': 387, 'CI': 396, 'CK': 405, 'CL': 414, 'CM': 423, 'CN': 432, 'CO': 441, 'CR': 450, 'CU': 459, 'CV': 468, 
	'CX': 477, 'CY': 486, 'CZ': 495, 'DE': 504, 'DJ': 513, 'DK': 522, 'DM': 531, 'DO': 540, 'DZ': 549, 'EC': 558, 'EE': 567, 'EG': 576, 'EH': 585, 
	'ER': 594, 'ES-CE': 603, 'ES-ML': 612, 'ES': 621, 'ET': 630, 'EU': 639, 'FI': 648, 'FJ': 657, 'FK': 666, 'FM': 675, 'FO': 684, 'FR': 693, 'GA': 702, 
	'GB': 711, 'GD': 720, 'GE': 729, 'GF': 738, 'GG': 747, 'GH': 756, 'GI': 765, 'GL': 774, 'GM': 783, 'GN': 792, 'GP': 801, 'GQ': 810, 'GR': 819, 
	'GS': 828, 'GT': 837, 'GU': 846, 'GW': 855, 'GY': 864, 'HK': 873, 'HM': 882, 'HN': 891, 'HR': 900, 'HT': 909, 'HU': 918, 'IC': 927, 'ID': 936, 
	'IE': 945, 'IL': 954, 'IM': 963, 'IN': 972, 'IO': 981, 'IQ': 990, 'IR': 999, 'IS': 1008, 'IT': 1017, 'JE': 1026, 'JM': 1035, 'JO': 1044, 'JP': 1053, 
	'KE': 1062, 'KG': 1071, 'KH': 1080, 'KI': 1089, 'KM': 1098, 'KN': 1107, 'KOSOVO': 1116, 'KP': 1125, 'KR': 1134, 'KW': 1143, 'KY': 1152, 'KZ': 1161, 
	'LA': 1170, 'LB': 1179, 'LC': 1188, 'LI': 1197, 'LK': 1206, 'LR': 1215, 'LS': 1224, 'LT': 1233, 'LU': 1242, 'LV': 1251, 'LY': 1260, 'MA': 1269, 
	'MC': 1278, 'MD': 1287, 'ME': 1296, 'MF': 1305, 'MG': 1314, 'MH': 1323, 'MK': 1332, 'ML': 1341, 'MM': 1350, 'MN': 1359, 'MO': 1368, 'MP': 1377, 
	'MQ': 1386, 'MR': 1395, 'MS': 1404, 'MT': 1413, 'MU': 1422, 'MV': 1431, 'MW': 1440, 'MX': 1449, 'MY': 1458, 'MZ': 1467, 'NA': 1476, 'NC': 1485, 
	'NE': 1494, 'NF': 1503, 'NG': 1512, 'NI': 1521, 'NKR': 1530, 'NL': 1539, 'NO': 1548, 'NP': 1557, 'NR': 1566, 'NU': 1575, 'NZ': 1584, 'OM': 1593, 
	'PA': 1602, 'PE': 1611, 'PF': 1620, 'PG': 1629, 'PH': 1638, 'PK': 1647, 'PL': 1656, 'PM': 1665, 'PN': 1674, 'PR': 1683, 'PS': 1692, 'PT': 1701, 
	'PW': 1710, 'PY': 1719, 'QA': 1728, 'RE': 1737, 'RO': 1746, 'RS': 1755, 'RU': 1764, 'RW': 1773, 'SA': 1782, 'SB': 1791, 'SC': 1800, 'SD': 1809, 
	'SE': 1818, 'SG': 1827, 'SH': 1836, 'SI': 1845, 'SJ': 1854, 'SK': 1863, 'SL': 1872, 'SM': 1881, 'SN': 1890, 'SO': 1899, 'SOUTH-OSSETIA': 1908, 
	'SR': 1917, 'ST': 1926, 'SV': 1935, 'SY': 1944, 'SZ': 1953, 'TC': 1962, 'TD': 1971, 'TF': 1980, 'TG': 1989, 'TH': 1998, 'TJ': 2007, 'TK': 2016, 
	'TL': 2025, 'TM': 2034, 'TN': 2043, 'TO': 2052, 'TR': 2061, 'TT': 2070, 'TV': 2079, 'TW': 2088, 'TZ': 2097, 'UA': 2106, 'UG': 2115, 'UM': 2124, 
	'US': 2133, 'UY': 2142, 'UZ': 2151, 'VA': 2160, 'VC': 2169, 'VE': 2178, 'VG': 2187, 'VI': 2196, 'VN': 2205, 'VU': 2214, 'WF': 2223, 'WS': 2232, 
	'YE': 2241, 'YT': 2250, 'ZA': 2259, 'ZM': 2268, 'ZW': 2277
};
