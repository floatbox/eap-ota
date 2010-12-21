$(function() {
    var ref = document.referrer;
    console.log(ref, window.history);
    if (ref && ref.indexOf(document.location.hostname) !== -1 && window.history && window.history.length > 1) {
        $('#back2search a').click(function(event) {
            event.preventDefault();
            window.history.back();
        });
    }
});