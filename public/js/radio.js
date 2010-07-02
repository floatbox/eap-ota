;(function($) {
    
$.fn.extend({
    radio: function(options) {

        options = $.extend({}, {
            active: 'train',
            cls: 'b-tabs'
        }, options || {});

        return this.each(function() {
            new app.Radio($(this), options);
        });
    }
});

app.Radio = function($el) {

    var $items = $el.find('*[onclick]');
    var value = null;
    var publisher = null;

    $items.each(function() {
        this.data = this.onclick();
        if ($(this).hasClass('active')) value = this.data.v;
    });

    $el.click(function(e) {
        e.preventDefault();
        if (!e.target.onclick) return;

        set(e.target.onclick().v);

        publisher && publisher.set(value, $el);
    });

    function set(v) {
        $items.each(function() {
            this.onclick().v == v ? $(this).addClass('active') : $(this).removeClass('active');
        });
        value = v;
    };

    $el.bind('set', function(e, v) {
        set(v);
    });

    $el.bind('get', function() {
        return value;
    });

    $el.bind('subscribe', function(e, p) {
        p.subscribe($el);
        publisher = p;
    });

    return this;
};

})(jQuery);
