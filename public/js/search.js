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
    if (updated && this.active) {
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
validate: function(qkey) {
    var self = this;
    var data = qkey ? {query_key: qkey} : this.getValues();
    this.toggle(false);
    if (!data) return;
    this.abortRequests();
    this.request = $.get("/pricer/validate/", data, function(result, status, request) {
        if (request != self.request) return;
        if (result.search) self.setValues(result.search);
        if (result.valid) {
            app.offers.load(data, result.human);
            if (data.query_key) {
                app.offers.show();
            } else {
                self.toggle(true);
            }
        }
        delete(self.request);
    });
},
getValues: function() {
    var data = $.extend({
        'search_type': 'travel',
        'day_interval': 1,
        'debug': $('#sdmode').get(0).checked ? 1 : 0
    }, this.fields);
    return (data.from && data.to) ? {search: data} : false;
},
setValues: function(data) {
    var self = this, fields = this.fields, update = {};
    for (var key in fields) {
        if (data[key] !== undefined) update[key] = data[key];
    }
    this.active = false;
    this.update(update, 'ajax');
    setTimeout(function() {
        self.active = true;
    }, 500);
},
abortRequests: function() {
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
},
toggle: function(mode) {
    $('#search-submit').toggleClass('disabled', !mode);
}
});

