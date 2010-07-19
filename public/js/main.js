
// надо будет как-то хэндлить дезактивированный js
$('HTML').addClass('JS');

// шоткат для консоли
window.l = window.console && console.log || alert;

// нэмспейс приложения
window.app = {};
app.search = {};
app.offers = {};

// 
// отсюда: http://sreznikov.blogspot.com/2010/01/supplant.html

String.prototype.supplant = function(o) {
    return this.replace(/{([^{}]*)}/g,
        function(a, b) {
            var r = o[b];
            return typeof r === 'string' || typeof r === 'number' ? r : a;
        }
    );
};