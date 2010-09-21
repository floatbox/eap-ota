app.constant = {
     DN : ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'],
     DNa: ['понедельник', 'вторник', 'среду', 'четверг', 'пятницу', 'субботу', 'воскресенье'], // винительный
    SDN : ['пон', 'втр', 'срд', 'чет', 'пят', 'суб', 'вск'],

     MN : ['январь', 'февраль', 'март', 'апрель', 'май', 'июнь', 'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'],
     MNg: ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'], // родительный
    SMN : ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'],

    numbers: {
        nomimative: ['ноль', 'один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять', 'десять', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать', 'двадцать'],
        collective: ['ноль', 'один', 'двое', 'трое', 'четверо', 'пятеро', 'шестеро', 'семеро', 'восьмеро']
    },

    countries: ['','abjasia','ad','ae','af','ag','ai','al','am','an','ao','aq','ar','as','at','au','aw','ax','az','ba','bb','bd','be','bf','bg','bh','bi','bj','bl','bm','bn','bo','br','bs','bt','bv','bw','by','bz','ca','cc','cd','cf','cg','ch','ci','ck','cl','cm','cn','co','cr','cu','cv','cx','cy','cz','de','dj','dk','dm','do','dz','ea_m','ea_s','ec','ee','eg','eh','er','es','et','eu','fi','fj','fk','fm','fo','fr','ga','gb','gd','ge','gf','gg','gh','gi','gl','gm','gn','gp','gq','gr','gs','gt','gu','gw','gy','hk','hm','hn','hr','ht','hu','ic','id','ie','il','im','in','io','iq','ir','is','it','je','jm','jo','jp','ke','kg','kh','ki','km','kn','kosovo','kp','kr','kw','ky','kz','la','lb','lc','li','lk','lr','ls','lt','lu','lv','ly','ma','mc','md','me','mf','mg','mh','mk','ml','mm','mn','mo','mp','mq','mr','ms','mt','mu','mv','mw','mx','my','mz','na','nc','ne','nf','ng','ni','nl','no','np','nr','nu','nz','om','pa','pe','pf','pg','ph','pk','pl','pm','pn','pr','ps','pt','pw','py','qa','re','ro','rs','ru','rw','sa','sb','sc','sd','se','sg','sh','si','sj','sk','sl','sm','sn','so','south_ossetia','sr','st','sv','sy','sz','tc','td','tf','tg','th','tj','tk','tl','tm','tn','to','tr','tt','tv','tw','tz','ua','ug','um','us','uy','uz','va','vc','ve','vg','vi','vn','vu','wf','ws','ye','yt','za','zm','zw']
}

app.utils = {
    /*
    словоформа множественного числа 
    @param {Number} число
    @param {Array} массив из трёх склонений: форма одного, двух и пяти

    пример: 'летело ' + n + ' ' + v$plural(n, ['утка', 'утки', 'уток'])
    */
    plural: function(n, fs) {
        n = parseInt(n) || 0;
        n = Math.abs(n) % 100;
        var n1 = n % 10;
        if (n > 10 && n < 20) return fs[2];
        if (n1 > 1 && n1 < 5) return fs[1];
        if (n1 == 1) return fs[0];
        return fs[2];
    }
}


//////// Расширения встроенных объектов /////////////

//////// Function /////////////

Function.prototype.extend = function(p) {
    var f = function(){};
    f.prototype = p.prototype;
    this.prototype = new f();
    this.prototype.constructor = this;
    this.superclass = p.prototype;
};


//////// String /////////////

String.prototype.supplant = function(o) { // см. http://sreznikov.blogspot.com/2010/01/supplant.html
    return this.replace(/{([^{}]*)}/g,
        function(a, b) {
            var r = o[b];
            return typeof r === 'string' || typeof r === 'number' ? r : a;
        }
    );
};

//////// Date /////////////

Date.prototype.clone = function() {
    return new Date(this.getTime());
};

Date.prototype.shift = function(days) {
    this.setDate(this.getDate() + days);
    return this;
};

Date.prototype.dayoff = function() {
    var dow = this.getDay();
    return (dow == 0 || dow == 6);
};

Date.prototype.toAmadeus = function() {
    var d = this.getDate();
    var m = this.getMonth() + 1;
    var y = this.getFullYear() % 100;
    return [d < 10 ? '0' : '', d, m < 10 ? '0' : '', m, y].join('');
};

Date.parseAmadeus = function(str) {
    var d = parseInt(str.substring(0,2), 10);
    var m = parseInt(str.substring(2,4), 10) - 1;
    var y = parseInt(str.substring(4,6), 10) + 2000;
    return new Date(y, m, d);
};

Date.daysInMonth = function(m, y) {
    var date = new Date(y, m, 1);
    date.setMonth(m + 1);
    date.setDate(0);
    return date.getDate();
};
