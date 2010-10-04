
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
    this.$fields = this.$el.find(':input[type="text"][onclick]').input(this);

    // this.$fields.extend(.. // радиокнопки инициализировать так же

    return this;
}

// форма заполнена корректно?

ptp.isValid = function() {
    var state = this.$fields.validate();
    return state.length == 0;
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

ptp.change = function() {
    this.setReady(this.isValid());

    return this;
}



// ======  Данные пассажиров ============


app.Person = function() {
    app.Person.superclass.constructor.apply(this, arguments)

    this.extra();

    return this;
};
app.Person.extend(app.Wizard);

var ptp = app.Person.prototype;

ptp.extra = function() {
    var me  = this;
    var cbx = $(':checkbox', this.$el);

    // чекбокс "бонусная карта"
    cbx.filter('.bonus').click(function() {
        var cb = this;
        var data = this.onclick();
        data.ctrls = $(data.ctrls);
        data.label = $(data.label);

        data.ctrls.each(function() {
            $(this)
            .toggleClass('g-none', !cb.checked)
            .attr('disabled', !cb.checked);
        });
        data.label.toggleClass('g-none', !cb.checked);

        me.change();
    });

    // чекбокс "нет срока действия"
    cbx.filter('.noexpiration').click(function() {
        var cb = this;
        var data = this.onclick();
        data.ctrls = $(data.ctrls);
        data.label = $(data.label);

        data.ctrls.each(function() {
            $(this)
            .attr('disabled', cb.checked)
            .toggleClass('text-disabled', cb.checked);
        });
        data.label.toggleClass('label-disabled', cb.checked);

        me.change();
    });


    // радиобаттон "Пол"
    var $sex = $('.bp-sex :radio', this.$el);
    $sex.change(function() {
        $sex.parent().removeClass('bp-sex-pressed bp-sex-invalid');
        $(this).parent().addClass('bp-sex-pressed');
        me.change();
    });

    // добавляем радиобаттон в коллекцию полей блока
    // в валидации используется только один баттон - остальные будут выцеплены валидатором по одинаковому имени
    this.$fields = this.$fields.add($sex[0]);
}

// ======  Данные банковской карты  ============

app.BankCard = function() {
    app.BankCard.superclass.constructor.apply(this, arguments)

this.name = 'BankCard';

    return this;
};
app.BankCard.extend(app.Wizard);


app.Contacts = function() {
    app.Contacts.superclass.constructor.apply(this, arguments)

    return this;
};
app.Contacts.extend(app.Wizard);


/*
app.Variant = function(el, i) {
    app.Variant.superclass.constructor.apply(this, arguments)

    return this;
};
app.Variant.extend(app.Wizard);


app.Submit = function() {
    app.Submit.superclass.constructor.apply(this, arguments)

    return this;
};
app.Submit.extend(app.Wizard);
*/

