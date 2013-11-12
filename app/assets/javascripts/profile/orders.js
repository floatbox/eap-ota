$(function() {
    
    var elem = $('#orders');

    var showDetails = function(order) {
        order.find('.orc-show').hide();
        order.find('.orc-hide').show();        
        order.find('.order-details').slideDown(250);
    };
    var hideDetails = function(order) {
        order.find('.orc-hide').hide();
        order.find('.orc-show').show();
        order.find('.order-details').slideUp(250);
    };
    elem.on('click', '.orc-show', function() {
        showDetails($(this).closest('.order'));
    });
    elem.on('click', '.orc-hide', function() {
        hideDetails($(this).closest('.order'));
    });
    
    $.get('/profile/orders', function(content) {
        elem.html(content);
        var orders = elem.find('.order');
        if (orders.length) {
            $('#pt-amount').html(orders.length).show();
        }
    });

});