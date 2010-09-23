
// надо будет как-то хэндлить дезактивированный js
$('HTML').addClass('JS');

// нэймспейс приложения
window.app = {};
app.search = {};
app.offers = {};

// шоткат для консоли

window.l = (document.location.host).indexOf('team') > -1 ? (window.console && console.log || alert) : $.noop;
