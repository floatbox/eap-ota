$(function() {
    var ref = document.referrer;
    if (ref && ref.indexOf(document.location.hostname) !== -1 && window.history && window.history.length > 1) {
        $('#back2search a').click(function(event) {
            event.preventDefault();
            window.history.back();
        });
    }
});