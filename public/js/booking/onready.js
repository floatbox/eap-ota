$(function() {

    // текстовые поля с подсказкой в value

    $('input.text[onclick]')
    .focus(function(e) {
        e = e.target;
        var d = e.onclick().defaultValue;
        var v = $.trim(e.value);

        //if (v == d) e.value = '';

        var f = function() {
            e.value = e.value.slice(1);
            e.value && window.setTimeout(f, 1);
        };

        v == d && f();
    })
    .blur(function(e) {
        e = e.target;
        var d = e.onclick().defaultValue;
        var v = $.trim(e.value);

        if (!v) e.value = d;
    });

    // раскрывающаяся подсказка

    $('.b-expand')
    .click(function(e) {
        var $u = $(this);
        $u.toggleClass('b-expand-up');
        
        $u = $u.next();

        $u.show();
    });



});
