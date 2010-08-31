(function($) {
    
$.fn.extend({
    timer: function() {
        return this.each(function() {
            new app.Timer($(this));
        });
    }
});

app.Timer = function($el) {

    var t1, t2;
    var interval = null;

    function update() {
        t2 = new Date();

        $el.text(((t2 - t1) / 1000).toFixed(1));
    };

    $el.bind('start', function() {
        t1 = new Date();
        interval = window.setInterval(update, 50);
    });

    $el.bind('stop', function() {
        interval && window.clearInterval(interval);
    });
};

})(jQuery);
