$(function() {

    app.wizard = $('.booking > form > .section[onclick]');

    app.wizard = $.map(app.wizard, function(el, i) {
        return new (app[el.onclick()])(el, i);
    });



    // раскрывающаяся подсказка

    $('.b-expand')
    .mousedown(function(e) {
        var $u = $(this);
        $u.toggleClass('b-expand-up');
        $u.next('p').slideToggle(200);
    });

    // текст тарифа

    $('#tarif-expand')
    .click(function(e) {
        e.preventDefault();
        $('#tarif-text').slideToggle(200);
    });



});
