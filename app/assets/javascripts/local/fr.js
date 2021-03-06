Date.prototype.human = function(year) {
    var parts = [this.getDate(), lang.monthes.gen[this.getMonth()]];
    if (year) parts[2] = this.getFullYear();
    return parts.join(' ');
};

var lang = {
errors: {
    timeout: 'Не удалось соединиться с сервером'
},
ordinalNumbers: {
    gen: ['первого', 'второго', 'третьего', 'четвертого', 'пятого', 'шестого', 'седьмого', 'восьмого'],
    dat: ['первому', 'второму', 'третьему', 'четвертому', 'пятому', 'шестому', 'седьмому', 'восьмому']
},
time: {
    hours: ['часа', 'часов', 'часов']
},
days: {
    today: 'сегодня',
    week: ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье']
},    
monthes: {
    nom: ['январь', 'февраль', 'март', 'апрель', 'май', 'июнь', 'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'],
    gen: ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'],
    pre: ['январе', 'феврале', 'марте', 'апреле', 'мае', 'июне', 'июле', 'августе', 'сентябре', 'октябре', 'ноябре', 'декабре'],
    abb: ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
},
pageTitle: {
    search: 'Поиск авиабилетов {0}',
    results: 'Авиабилеты {0}',
    booking: 'Покупка авиабилетов {0}'
},
searchRequests: {
    dpt: 'Введите, пожалуйста, пункт отправления {0}',
    arv: 'Введите, пожалуйста, пункт назначения {0}',
    date: 'Выберите, пожалуйста, дату {0}',
    rtsegments: ['вылета', 'обратного вылета'],
    mwsegments: ['первого перелета', 'второго перелета', 'третьего перелета', 'четвертого перелета', 'пятого перелета', 'шестого перелета'],
    persons: 'Количество пассажиров не должно быть больше восьми',
    infants: 'Младенцев без места не должно быть больше, чем взрослых',
    noadults: 'Дети не могут лететь без взрослых'
},
mapControl: {
    expand: 'Развернуть карту',
    collapse: 'Свернуть карту'
},
priceMap: {
    link: 'Куда дешево улететь<br>{0}<br>в&nbsp;{1}?',
    limit: 'цена до {0} <span class="ruble">Р</span>'
},
results: {
    cheap: {
        one: 'Дешевый',
        many: 'Дешевые'
    },
    optimal: {
        one: 'Оптимальный',
        many: 'Оптимальные'
    },
    nonstop: {
        one: 'Прямой',
        many: 'Прямые'
    },
    cheapNonstop: {
        one: 'Дешевый прямой',
        many: 'Дешевые прямые'
    },
    matrix: {
        one: '± 3 дня',
        many: '± 3 дня'
    },
    some: '{0} из {1}',
    all: 'Все {0}'    
},
segment: {
    title: 'Перелет {0}',
    directions: ['туда', 'обратно'],
    more: 'и еще {0} перелета {1}',    
    variants: ['вариант', 'варианта', 'вариантов'],
    incompatible: {
        rt: 'с другим <span class="ossi-segment">обратным перелётом</span>',
        one: 'с другим <span class="ossi-segment">перелётом {0}</span>',
        many: 'с другими перелётами {0}'
    }
},
price: {
    buy: 'Купить за {0}',
    one: 'итоговая цена',
    many: 'итоговая цена за всех',
    from: 'от {0}',    
    rise: 'на {0} дороже',
    fall: 'на {0} дешевле',
    profit: ' <span class="obs-profit">на <strong>{0}%</strong> дешевле, чем в среднем</span>'
},
currencies: {
    RUR: ['рубль', 'рубля', 'рублей']
},
filters: {
    reset: 'Сбросить {0}',
    selected: ['выбранный фильтр', 'выбранных фильтра', 'выбранных фильтров'],
    fromto: 'от {0} до {1}',
    less: 'меньше {1}',
    any: 'любая',
    short: 'короткие',
    long: 'длинные'
},
passengers: {
    one: 'Пассажир',
    many: 'Пассажиры'
},
passengersData: {
    one: 'данные пассажира',
    many: 'данные пассажиров',
    required: 'Заполните {0},<br> чтобы узнать новую стоимость.'
},
formValidation: {
    otherFields: function(n) {
        return 'еще ' + n.decline('поле', 'поля', 'полей');
    },
    emptyFields: function(items) {
        return 'Осталось заполнить ' + items.enumeration(' и&nbsp;') + '.';
    },
    email: {
        empty: '{адрес электронной почты}',
        wrong: 'Неправильно введен {адрес электронной почты}.'
    },
    phone: {
        empty: '{номер телефона}',
        letters: 'В {номере телефона} можно использовать только цифры.',
        short: 'Короткий {номер телефона}, не забудьте ввести код страны и города.'
    },
    fname: {
        empty: '{имя пассажира}',
        short: '{Имя пассажира} нужно ввести полностью.',
        letters: '{Имя пассажира} нужно ввести латинскими буквами.'
    },
    lname: {
        empty: '{фамилию пассажира}',
        short: '{Фамилию пассажира} нужно ввести полностью.',
        letters: '{Фамилию пассажира} нужно ввести латинскими буквами.'
    },
    gender: {
        empty: '{пол пассажира}'
    },
    birthday: {
        empty: '{дату рождения} пассажира',
        wrong: 'Указана несуществующая {дата рождения} пассажира.',
        letters: '{Дату рождения} пассажира нужно ввести цифрами в формате дд/мм/гггг.',
        improper: '{Дата рождения} пассажира не может быть позднее сегодняшней.'
    },
    passport: {
        empty: '{номер документа} пассажира',
        letters: 'В {номере документа} нужно использовать только буквы и цифры.'
    },
    expiration: {
        empty: '{срок действия документа} пассажира',
        wrong: 'Указана несуществующая дата в {сроке действия документа} пассажира.',
        letters: '{Срок действия документа} нужно ввести цифрами в формате дд/мм/гггг.',
        improper: '{Срок действия документа} уже истёк.'
    },
    bonus: {
        empty: '{номер бонусной карты} пассажира',
        letters: '{Номер бонусной карты} нужно ввести латинскими буквами и цифрами.',
    },
    cardnumber: {
        empty: '{номер банковской карты}',
        letters: '{Номер банковской карты} нужно ввести цифрами.',
        wrong: '{Номер банковской карты} введён неправильно.'    
    },
    cvc: {
        empty: '{CVV/CVC код банковской карты}',
        letters: '{CVV/CVC код банковской карты} нужно ввести цифрами.',
    },
    cardholder: {
        empty: '{имя владельца банковской карты}',
        letters: '{Имя владельца банковской карты} нужно ввести латинскими буквами.',
    },
    cardexp: {
        empty: '{срок действия банковской карты}',
        letters: '{Срок действия банковской карты} нужно ввести цифрами в формате мм/гг.',
        wrong: 'Месяц в {сроке действия банковской карты} не может быть больше 12.',
        improper: '{Срок действия банковской карты} уже истёк.'
    },
    address: {
        empty: '{адрес доставки}'
    }
}
};
