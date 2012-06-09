$(function() {
    var rhost = document.referrer && document.referrer.split('#')[0].replace(/https?:\/\/|\/$/g, ''); 
    var phost = document.location.host;
    console.log(rhost, phost);
    if (rhost === phost && window.history && window.history.length > 1) {
        $('#back2search a').html('Вернуться к поиску').click(function(event) {
            event.preventDefault();
            window.history.back();
        });
    }
});
trackPage();
