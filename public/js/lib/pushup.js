/* 
 * Original Copyright
 * 
 * Pushup
 * Copyright (c) 2008 Nick Stakenburg (www.nickstakenburg.com)
 *
 * License: MIT-style license.
 * Website: http://www.pushuptheweb.com
 *
 */

/* 
 * Modified for jQuery by Stuart Loxton (www.stuartloxton.com)
*/

(function ($) {
    // Cookie plugin based on the work of Peter-Paul Koch - http://www.quirksmode.org
    var Cookie = {
        set: function (name, value) {
            var expires = '', options = arguments[2] || {}, date;
            if (options.duration) {
                date = new Date();
                date.setTime(date.getTime() + options.duration * 1000 * 60 * 60 * 24);
                value += '; expires=' + date.toGMTString();
            }
            document.cookie = name + "=" + value + expires + "; path=/";
        },

        remove: function (name) { 
            this.set(name, '', -1);
        },

        get: function (name) {
            var cookies = document.cookie.split(';'), nameEQ = name + "=", i, l, c;
            for (i = 0, l = cookies.length; i < l; i++) {
                c = cookies[i];
                while (c.charAt(0) === ' ') {
                    c = c.substring(1, c.length);
                }
                if (c.indexOf(nameEQ) === 0) {
                    return c.substring(nameEQ.length, c.length);
                }
            }
            return null;
        }
    };

    $.pushup = {
	    Version: '1.0.3',
	    options: {
		    appearDelay: 0.5,
		    fadeDelay: 15,
		    images: '/img/pushup/',
		    message: 'Вы пользуетесь старой версией браузера. Некоторые функции сайта могут не работать. <a>Обновите</a> свой браузер.',
		    reminder: {
			    hours: 168,
			    message: 'Больше не напоминать'
		    }
	    },
	    activeBrowser: null,
	    updateLinks: {
		    IE: 'http://www.microsoft.com/rus/windows/internet-explorer/',
		    Firefox: 'http://www.mozilla.com/ru/firefox/',
		    Safari: 'http://www.apple.com/ru/safari/download/',
		    Opera: 'http://www.opera.com/download/'
	    },
	    browsVer: {
		    Firefox: (navigator.userAgent.indexOf('Firefox') > -1) ? parseFloat(navigator.userAgent.match(/Firefox[\/\s](\d+)/)[1]) : false,
		    IE: ($.browser.msie) ? parseFloat($.browser.version) : false,
		    Safari: ($.browser.safari) ? parseFloat($.browser.version) : false,
		    Opera: ($.browser.opera) ? parseFloat($.browser.version) : false
	    },
	    browsers: {
		    Firefox: 3,
		    IE: 8,
		    Opera: 9.5,
		    Safari: 3
	    },
	    init: function () {
		    $.each($.pushup.browsVer, function (i, browserVersion) {
			    if (browserVersion && browserVersion < $.pushup.browsers[i]) {
				    $.pushup.activeBrowser = i;
				    if (!$.pushup.options.ignoreReminder && $.pushup.cookiesEnabled && Cookie.get('_pushupBlocked')) { 
				        return; 
				    } else {
					    var time = ($.pushup.options.appearDelay !== undefined) ? $.pushup.options.appearDelay * 1000 : 0;
					    setTimeout($.pushup.show, time);
				    }
			    }
		    });
	    },
	    show: function () {
	        var $elm, $icon, $message, $messageLink, hours, H, messageText, $hourElem, imgSrc, srcFol, image, styles, time;
		    $elm = $(document.createElement('div'))
		        .attr('id', 'pushup')
		        .hide()
		        .appendTo('body');
		    $messageLink = $(document.createElement('span'))
		        .addClass('pushup_messageLink')
		        .appendTo($elm);
		    $icon = $(document.createElement('div'))
		        .addClass('pushup_icon')
		        .appendTo($messageLink);
		    $message = $(document.createElement('span'))
		        .addClass('pushup_message')
		        .html($.pushup.options.message)
		        .appendTo($messageLink);
		    $message.find('a')
		        .attr('target', '_blank')
		        .attr("href", $.pushup.updateLinks[$.pushup.activeBrowser]);
    		
		    hours = $.pushup.options.reminder.hours;
		    if (hours && $.pushup.cookiesEnabled) {
			    H = hours + ' hour' + (hours > 1 ? 's' : '');
			    messageText = $.pushup.options.reminder.message.replace('#{hours}', H);
			    $hourElem = $(document.createElement('span'))
			        .addClass('link')
			        .html(messageText);
			    $elm.append($('<p/>').addClass('pushup_reminder').append($hourElem));
			    $hourElem.click(function() {
				    $.pushup.setReminder($.pushup.options.reminder.hours);
				    $.pushup.hide();
			    });
		    }
		    if (/^(https?:\/\/|\/)/.test($.pushup.options.images)) {
			    imgSrc = $.pushup.options.images;
		    } else {
			    $('script[src]').each(function (i, elem) {
			        var $elem = $(elem);
				    if (/jquery\.pushup/.test($elem.attr('src'))) {
					    srcFol =  $elem.attr('src').replace('jquery.pushup.js', '');
					    imgSrc = srcFol + $.pushup.options.images;
				    }
			    });
		    }
		    image = imgSrc + $.pushup.activeBrowser.toLowerCase();
		    styles = ($.pushup.browsVer.IE < 7 && $.pushup.browsVer.IE) ? {
			    filter: 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'' + image + '.png\'\', sizingMethod=\'crop\')'
		    } : {
			    background: 'url(' + image + '.png) no-repeat top left'
		    };
		    
		    $icon.css(styles);
		    $elm.fadeIn('slow');
		    
		    if ($.pushup.options.fadeDelay !== undefined) {
			    time = $.pushup.options.fadeDelay * 1000;
			    setTimeout($.pushup.hide, time);
		    }
	    },
	    hide: function () { 
	        $('#pushup').fadeOut('slow'); 
	    },
	    setReminder: function (hours) {
		    Cookie.set('_pushupBlocked', 'blocked', { duration: 1 / 24 * hours });
	    },
	    resetReminder: function () { 
	        Cookie.remove('_pushupBlocked');
	    }
    };

    $.pushup.cookiesEnabled = (function (test) {
        if (Cookie.get(test)) {
            return true;
        }
        Cookie.set(test, 'test', { duration: 15 });
        return Cookie.get(test);
    }('_pushupCookiesEnabled'));
    $(function () {
        $.pushup.init();
    });
}(jQuery));