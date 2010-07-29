$.extend(app.search, {
tools: {},
fields: {},
getField: function(key) {
	return this.fields[key] || this.addField(key);
},
addField: function(key, check, value) {
	return this.fields[key] = {
		value: value,
		required: Boolean(check),
		check: typeof check == 'function' && check,
	};
},
update: function(data, source) {
    clearTimeout(this.sendTimer);
    var updated = false;
    for (var key in data) {
    	var value = data[key];
		var field = this.getField(key);
    	if (value != field.value) {
    		field.value = value;
    		var callbacks = this.callbacks[key];
    		if (callbacks) {
	    		for (var i = 0; cb = callbacks[i]; i++) {
	    			if (cb.source != source) cb.handler(value);
	    		}
    		}
    		updated = true;
    	}
    }
    if (source && updated) {
        var self = this;
        this.sendTimer = setTimeout(function() {
            self.send();
        }, 250);
    }
},
callbacks: {},
subscribe: function(source, key, handler) {
	var callbacks = this.callbacks[key] || (this.callbacks[key] = []);
	callbacks.push({
		source: source,
		handler: handler
	});
},
send: function(data) {
    var data = {
        "search_type": "travel",
        "debug": 1,
        "adults": 1,
        "children": 0,
        "nonstop": 0,
        "day_interval": 1
    }
    for (var key in this.fields) {
        var field = this.fields[key];
        if (field.required && !(field.check ? field.check(field.value) : field.value)) {
        	return;
        }
        data[key] = field.value;
    }
	this.transcript(data);
    app.offers.load(data);
},
transcript: function(data) {
    // Заполнение заголовка, пока не сделаем аяксовое
	var $transcript = $("#search-transcript");
	var monthes = app.constant.MNg;
    if (data.rt) {
        var d1 = Date.parseAmadeus(data.date1);
        var d2 = Date.parseAmadeus(data.date2);
        var words = [d1.getDate(), monthes[d1.getMonth()], d2.getDate(), monthes[d2.getMonth()]];
        if (words[1] == words[3]) words[1] = "по"; else words[1] += " по";
        $("h1", $transcript).html(data.from + " &rarr; " + data.to + " и&nbsp;обратно c " + words.join(" "));
    } else {
        var d1 = Date.parseAmadeus(data.date1); 
        $("h1", $transcript).html(data.from + " &rarr; " + data.to + " " + d1.getDate() + ' ' + monthes[d1.getMonth()]);
    }
    $transcript.removeClass("g-none");
    var w = $(window), wst = w.scrollTop();
    var offset = $transcript.offset().top;
    if (offset - wst > w.height() / 2) {
        $({st: wst}).animate({
            st: offset - 112
        }, {
            duration: 500,
            step: function() {
                w.scrollTop(this.st);
            }
        });
    }
}
});
