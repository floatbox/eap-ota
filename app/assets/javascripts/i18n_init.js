//= require i18n
//= require i18n/translations

I18n.locale = 'ru';
I18n.default_locale = 'ru';
I18n.pluralizationRules.ru = function (n) {
    return n % 10 == 1 && n % 100 != 11 ? "one" :
           [2, 3, 4].indexOf(n % 10) >= 0 && [12, 13, 14].indexOf(n % 100) < 0 ? "few" :
           n % 10 == 0 || [5, 6, 7, 8, 9].indexOf(n % 10) >= 0 || [11, 12, 13, 14].indexOf(n % 100) >= 0 ? "many" :
           "other";
};

$(function() {
    $('#page-header .ph-lang .link').on('click', function() {
        Cookie('language', $(this).text() === 'English' ? 'en' : undefined, new Date(2015, 0, 1));
        window.location.reload(true);
    });
});
