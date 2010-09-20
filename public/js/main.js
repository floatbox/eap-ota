
// надо будет как-то хэндлить дезактивированный js
$('HTML').addClass('JS');

// нэймспейс приложения
window.app = {};
app.search = {};
app.offers = {};

// шоткат для консоли

window.app._debug = (document.location.host).indexOf('team') > -1;
window.l = window.app._debug ? (window.console && console.log || alert) : $.noop;
