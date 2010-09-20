
// базовый класс для шагов бронирования

app.Wizard = function(el, i) {
    this.el = el;
    this.$el = $(el);
    this.index = i;

    this.ready = this.$el.hasClass('ready');

    this.init();

    return this;
};

var ptp = app.Wizard.prototype;

ptp.init = function() {
    this.$fields = this.$el.find(':input[type="text"][onclick]');

    this.$fields.input();


//    this.$fields.trigger('mark', true);

//    this.$fields.each(function(i, el){
//    });


    return this;
}

// форма заполнена корректно?

ptp.validate = function() {
    return this;
}


// сделать блок жёлтым или зелёным

ptp.setReady = function(ready) {
    this.ready = ready;
    this.$el.toggleClass('ready', ready);

    return this;
}

ptp.isReady = function() {
    return this.ready;
}


// 

ptp.onFocus = function() {
    return this;
}

ptp.onBlur = function() {
    return this;
}

ptp.onChange = function() {
    return this;
}



// ================================================================

app.Variant = function(el, i) {
    app.Variant.superclass.constructor.apply(this, arguments)

    return this;
};
app.Variant.extend(app.Wizard);


app.Person = function() {
    app.Person.superclass.constructor.apply(this, arguments)

    return this;
};
app.Person.extend(app.Wizard);


app.BankCard = function() {
    app.BankCard.superclass.constructor.apply(this, arguments)

    return this;
};
app.BankCard.extend(app.Wizard);


app.Contacts = function() {
    app.Contacts.superclass.constructor.apply(this, arguments)

    return this;
};
app.Contacts.extend(app.Wizard);


app.Submit = function() {
    app.Submit.superclass.constructor.apply(this, arguments)

    return this;
};
app.Submit.extend(app.Wizard);


