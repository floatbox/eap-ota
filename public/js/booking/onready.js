$(function() {

    app.wizard = $.map($('dl.booking > dd'), function(el, i){
        return new (app[el.onclick()])(el, i);
    });



    // текстовые поля с подсказкой в value

    $('input.text[onclick]')
    .focus(function(e) {
        e = e.target;
        var d = e.onclick().defaultValue;
        var v = $.trim(e.value);

        if (v == d) e.value = '';
    })
    .blur(function(e) {
        e = e.target;
        var d = e.onclick().defaultValue;
        var v = $.trim(e.value);

        if (!v) e.value = d;
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
