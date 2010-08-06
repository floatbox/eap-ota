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
        clearTimeout(this.sendTimer);
        var self = this;
        this.sendTimer = setTimeout(function() {
            self.send();
        }, 350);
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
    var self = this, data = {
        'search_type': 'travel',
        'day_interval': 1,
        'debug': $('#sdmode').get(0).checked ? 1 : 0
    }
    for (var key in this.fields) {
        var field = this.fields[key];
        if (field.required && !(field.check ? field.check(field.value) : field.value)) {
            self.toggle(false);
            return;
        }
        data[key] = field.value;
    }
    $.get("/pricer/validate/", {
        search: data
    }, function(result) {
        self.toggle(result.valid);
        if (result.valid) {
            var $transcript = $('#search-transcript');
            $transcript.children('h1').html(result.human);
            $transcript.removeClass('g-none');
            app.offers.load(data);  
        }
    });
},
toggle: function(mode) {
    $('#search-submit').toggleClass('disabled', !mode);
    if (!mode) {
        $("#offers").addClass("latent");
        $('#search-transcript').addClass('latent');           
    }
},
submit: function() {
    $("#offers").removeClass("latent");
    var $transcript = $('#search-transcript').removeClass('latent');
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

