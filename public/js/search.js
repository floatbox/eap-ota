app.search.tools = {};
app.search.fields = {};
app.search.addField = function(key, check) {
	this.fields[key] = {
		value: undefined,
		required: check != undefined,
		check: typeof check == 'function' && check,
		callbacks: []
	};
}
app.search.update = function(data, source) {
    clearTimeout(this.sendTimer);
    var updated = false;
    for (var key in data) {
    	var value = data[key];
		var field = this.fields[key];
    	if (field && value != field.value) {
    		field.value = value;
    		for (var i = 0; cb = field.callbacks[i]; i++) {
    			if (cb.source != source) cb.handler(value);
    		}
    		updated = true;
    	}
    }
    if (updated) {
	    var self = this;
	    this.sendTimer = setTimeout(function() {
    		self.send();
	    }, 250);
	}
};
app.search.subscribe = function(source, key, handler) {
	var field = this.fields[key];
	if (field) field.callbacks.push({
		source: source,
		handler: handler
	});
};
app.search.send = function(data) {
    var data = {
        "search_type": "travel",
        "debug": 0,
        "adults": 1,
        "children": 0,
        "nonstop": 0,
        "day_interval": 1
    }
    for (var key in this.fields) {
		var field = this.fields[key];
        if (field.required && !(field.check ? field.check(field.value) : field.value)) return;
        data[key] = field.value;
    }
    app.offers.showLoader(data);
    $.get("/pricer/", {
        search: data
    }, function(s) {
        $("#offers\\.loader").addClass("g-none");
        if (typeof s == "string") {
            app.offers.update(s);
        } else {
            alert(s && s.exception && s.exception.message);
        }
    });
};

app.offers.showLoader = function(data) {
    // Заполнение заголовка, пока не сделаем аяксовое
    var monthes = app.constant.MNg;
    if (data.rt) {
	    var d1 = Date.parseAmadeus(data.date1);
	    var d2 = Date.parseAmadeus(data.date2);
	    var words = [d1.getDate(), monthes[d1.getMonth()], d2.getDate(), monthes[d2.getMonth()]];
	    if (words[1] == words[3]) words[1] = "по"; else words[1] += " по";
	    $("#offers\\.transcript s").html(data.from + " &rarr; " + data.to + " и&nbsp;обратно c " + words.join(" "));
	} else {
	    var d1 = Date.parseAmadeus(data.date1);	
	    $("#offers\\.transcript s").html(data.from + " &rarr; " + data.to + " " + d1.getDate() + ' ' + monthes[d1.getMonth()]);
	}

    $("#offers\\.transcript").removeClass("g-none");
    $("#offers\\.loader").removeClass("g-none");
    var w = $(window);
    var cst = w.scrollTop();
    var offset = $("#media").offset().top;
    if (offset - cst > w.height() / 2) {
        $({st: cst}).animate({
            st: offset - 112
        }, {
            duration: 500,
            step: function() {
                w.scrollTop(this.st);
            }
        });
    }
};

app.offers.update = function(s) {
	$("#offers").html(s).removeClass("g-none");
};

