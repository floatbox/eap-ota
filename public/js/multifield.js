
app.MultiField = function(options) {
    var me = this;

    options = $.extend({}, {
        value: null,
        cls: ''
    }, options || {});


    this.value = null;

    this.subscribers = [];

    options.value && this.set(options.value);

    return this;
};

app.MultiField.prototype = {
    subscribe: function(e) {
        // может, проверять подписчиков на уникальность?
        this.subscribers.push(e);
    },

    set: function(v, source) {
        this.value = v;
        $.each(this.subscribers, function() {
            this != source && this.trigger('set', v);
        });
    },

    get: function() {
        return this.value;
    }

}
