$(function() {
    if (browser.scanty) return;
    var fixed = false;
    var canvas = $(window).scroll(function() {
        toggle();
    });
    var toggle = function() {
        var st = canvas.scrollTop();
        if (st > bhtop !== fixed) {
            fixed = st > bhtop;
            bheader.toggleClass('bh-static', !fixed);
        }
    };
    var bheader = $('#booking .booking-header');
    var bhtop = bheader.offset().top;
    $('#booking .bh-placeholder').height(bheader.height());
});
