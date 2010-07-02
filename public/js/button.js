;(function($) {
    
$.fn.extend({
    button: function() {
        return this.each(function() {
            new app.Button($(this));
        });
    }
});

app.Button = function($el) {

    var el = $el[0];
    var values = (el.onclick && el.onclick()) || [];
    var value = null;
    var publisher = null;

    // в каком состоянии кнопка сейчас?
    var state = values.length - 1;
    while (state >= 0 && !$el.hasClass('button-' + values[state].cls)) state--;
    if (state < 0) return;
    value = values[state].cls;

    $el.click(function(e) {
        e.preventDefault();
        set(values[(state + 1) % values.length].v);
        publisher && publisher.set(value, $el);
    });

    function set(v) {
        $el.removeClass('button-' + values[state].cls);

        value = v;
        state = values.length - 1;
        while (state >= 0 && values[state].v != value) state--;
        if (state < 0) return;

        $el.attr('title', values[state].t);
        $el.addClass('button-' + values[state].cls);
    };

    $el.bind('set', function(e, v) {
        $.each(values, function(i) {
            if (this.v != v) return true;
            set(v);
            return false;
        });
    });

    $el.bind('get', function() {
        return value;
    });

    $el.bind('subscribe', function(e, p) {
        publisher = p;
        p.subscribe($el);
    });

    return this;
};

})(jQuery);