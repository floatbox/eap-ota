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
        this.toggle(false);
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
    this.toggle(false);
    if (!data) {
        var data = $.extend({
            'search_type': 'travel',
            'day_interval': 1,
            'debug': $('#sdmode').get(0).checked ? 1 : 0
        }, this.fields);
    
        // Временная проверка, пока нет распознавания дат
        if (!(data.to && data.from && data.date1 && (data.date2 || !data.rt))) {
            return;
        }
    }
        
    if (this.request && this.request.abort) {
        this.request.abort();
    }
    if (app.offers.loading.is(':visible')) {
        app.offers.container.addClass('g-none');
    }
    var au = app.offers.update;
    if (au && au.request && au.request.abort) {
        au.request.abort();
        delete(au.request);
    }
    this.request = $.get("/pricer/validate/", {
        search: data
    }, function(result, status, request) {
        if (request != self.request) return;
        if (result.query_key) {
            app.offers.load({query_key: query_key}, result.human);
        } else if (result.valid) {
            app.offers.load({search: data}, result.human);
        }
        self.toggle(result.valid);
        delete(self.request);
    });
},
toggle: function(mode) {
    $('#search-submit').toggleClass('disabled', !mode);
}
});

