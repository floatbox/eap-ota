$(function() {
    var ref = document.referrer, host = document.location.hostname;
    if (ref && window.history && window.history.length > 1) {
        var pos = ref.indexOf(host);
        if (pos !== -1 && ref.substring(pos + host.length).length < 2) {
            $('#back2search a').click(function(event) {
                event.preventDefault();
                window.history.back();
            });
        }
    }
});