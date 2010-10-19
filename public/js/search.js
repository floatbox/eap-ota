$.extend(app.search, {
tools: {},
fields: {},
update: function(data, source) {
    var updated = false;
    for (var key in data) {
        var dv = data[key], fv = this.fields[key];
        if (dv != fv) {
            this.fields[key] = dv;
            var callbacks = this.callbacks[key];
            if (callbacks) {
                for (var i = 0; cb = callbacks[i]; i++) {
                    if (cb.source != source) cb.handler(dv);
                }
            }
            updated = true;
        }
    }
    if (source && updated) {
        var self = this;
        clearTimeout(this.vtimer);
        this.vtimer = setTimeout(function() {
            self.validate();
        }, 750);
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
validate: function(data) {
    var self = this;
    if (!data) {
        var data = $.extend({
            'search_type': 'travel',
            'day_interval': 1,
            'debug': $('#sdmode').get(0).checked ? 1 : 0
        }, this.fields);
    
        // Временная проверка, пока нет распознавания дат
        if (!(data.to && data.from && data.date1 && (data.date2 || !data.rt))) {
            self.toggle(false);
            return;
        }
    }
    
    if (this.request && this.request.abort) {
        this.request.abort();
        this.request = undefined;
    }
    var ao = app.offers, u = ao.update;
    if (u.request) {
        u.aborted = true;
        if (u.request.abort) u.request.abort();
        ao.container.addClass('g-none');
        ao.toggle('empty');
    }
    this.request = $.get("/pricer/validate/", {
        search: data
    }, function(result) {
        self.toggle(result.valid);
        self.request = undefined;
        if (result.query_key) {
            app.offers.load({query_key: query_key}, result.human);
        } else if (result.valid) {
            app.offers.load({search: data}, result.human);
        }
    });
},
toggle: function(mode) {
    $('#search-submit').toggleClass('disabled', !mode);
}
});

