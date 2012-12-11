Date.prototype.human = function(year) {
    var parts = [this.getDate(), lang.monthes.gen[this.getMonth()]];
    if (year) parts[2] = this.getFullYear();
    return parts.join(' ');
};

var lang = {
errors: {
    timeout: 'Server is unreachable. Check your internet connection.'
},
ordinalNumbers: {
    gen: ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth'],
    dat: ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth']
},
time: {
    hours: ['hours', 'hours', 'hours']
},
days: {
    today: 'today',
    week: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
},    
monthes: {
    nom: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    gen: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    pre: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    abb: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
},
pageTitle: {
    search: 'Airline tickets search {0}',
    results: 'Airline tickets {0}',
    booking: 'Booking airline tickets {0}'
},
searchRequests: {
    dpt: 'Please enter departure city or airport {0}',
    arv: 'Please enter city or airport of destination {0}',
    date: 'Please select date of {0}',
    rtsegments: ['departure', 'return'],
    mwsegments: ['first flight', 'second flight', 'third flight', 'fourth flight', 'fifth flight', 'sixth flight'],
    persons: 'Number of passengers should be eight or less',
    infants: 'Number of unseated infants snould not exceed number of adult passengers',
    noadults: 'Children must be accompanied by adults'
},
mapControl: {
    expand: 'Expand map',
    collapse: 'Collapse map'
},
priceMap: {
    link: 'Low-priced flights<br>{0}<br>in&nbsp;{1}?',
    limit: 'price up to {0} <span class="ruble">Р</span>'
},
results: {
    cheap: {
        one: 'Cheap',
        many: 'Cheap'
    },
    optimal: {
        one: 'Optimal',
        many: 'Optimal'
    },
    nonstop: {
        one: 'Direct',
        many: 'Direct'
    },
    cheapNonstop: {
        one: 'Cheap direct',
        many: 'Cheap direct'
    },
    matrix: {
        one: '± 3 days',
        many: '± 3 days'
    },
    some: '{0} of {1}',
    all: 'All {0}'    
},
segment: {
    title: 'Flight {0}',
    directions: ['depart', 'return'],
    more: 'and {0} flight {1}',    
    variants: ['option', 'options', 'options'],
    incompatible: {
        rt: 'with other <span class="ossi-segment">return flight</span>',
        one: 'with other <span class="ossi-segment">flight {0}</span>',
        many: 'with other flights {0}'
    }
},
price: {
    buy: 'Buy for {0}',
    one: 'total price',
    many: 'total price for all passengers',
    from: 'from {0}',    
    rise: '{0} more expensive',
    fall: '{0} cheaper',
    profit: ' <span class="obs-profit">на <strong>{0}%</strong> cheaper then average</span>'
},
currencies: {
    RUR: ['Rubles', 'Rubles', 'Rubles']
},
filters: {
    reset: 'Reset {0}',
    selected: ['selected filter', 'selected filters', 'selected filters'],
    fromto: 'from {0} to {1}',
    less: 'less then {1}',
    any: 'any',
    short: 'short',
    long: 'long'
},
passengers: {
    one: 'Passenger',
    many: 'Passengers'
},
passengersData: {
    one: 'Passenger',
    many: 'Passengers',
    required: 'Fill in {0},<br> to recalculate price'
},
formValidation: {
    email: {
        empty: '{email address}',
        wrong: 'Incorrect {email address}.'
    },
    phone: {
        empty: '{Phone number}',
        letters: '{Phone number} must contain only numbers.',
        short: 'Short {phone number}, enter country and area code.'
    },
    fname: {
        empty: '{passenger name}',
        short: '{Passenger name} should be entered completely.',
        letters: '{Passenger name} should be entered by latin letters.'
    },
    lname: {
        empty: '{passenger last name}',
        short: '{Passenger last name} should be entered completely.',
        letters: '{Passenger last name} should be entered by latin letters.'
    },
    gender: {
        empty: '{passenger gender}'
    },
    birthday: {
        empty: 'passenger {birthdate}',
        wrong: 'Passenger {birthdate} doesn't exist.',
        letters: 'Passenger {birthdate} should be entered in dd/mm/yyyy format.',
        improper: 'Passenger {birthdate} should not be later than today.'
    },
    passport: {
        empty: 'passenger {document number}',
        letters: 'Passenger {document number} must contain only letters and numbers.'
    },
    expiration: {
        empty: 'Passenger {document expiry date}',
        wrong: 'Passenger {document expiry date} is incorrect.',
        letters: 'Passenger {document expiry date} should be entered in dd/mm/yyyy format.',
        improper: 'Passenger document is expired'
    },
    bonus: {
        empty: '{bonus card number}',
        letters: '{Bonus card number} must contain only latin letters and numbers.',
    },
    cardnumber: {
        empty: '{card number}',
        letters: '{Card number} must contain only numbers.',
        wrong: '{Card number} is incorrect.'    
    },
    cvc: {
        empty: '{CVV/CVC code of bank card}',
        letters: '{CVV/CVC code of bank card} must contain only numbers.',
    },
    cardholder: {
        empty: '{Cardholder name}',
        letters: '{Cardholder name} must contain only latin letters.',
    },
    cardexp: {
        empty: '{card expiry date}',
        letters: '{Card expiry date} should be in mm/yy format.',
        wrong: 'The month of {card expiry date} should not be more than 12.',
        improper: 'Bank card is expired.'
    },
    address: {
        empty: '{delivery address}'
    }
}
};