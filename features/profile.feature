# language: ru
Функционал: Профиль

  Я, пользователь, могу зарегистрироваться и завести личный кабинет (профиль) на сайте для того, чтобы облегчить себе процесс покупки билетов.
  И личный кабинет будет всячески помогать мне в процессе оформления и покупки билетов, а также предложит всяческие ништяки.

  Сценарий: незалогиненный пользователь ломится в личный кабинет.
    Система предлагает ему две формы: регистрация и авторизация.

  Сценарий: залогиненный пользователь ломится в личный кабинет. Система показывает ему вкладку "Заказы"
  
  Сценарий: пользователь регистрируется на сайте. 
    Допустим юзер ввел e-mail и нажал кнопку "зарегистрироваться"
    Если e-mail валидный
    То система генерирует и шлет пользователю подтверждающее письмо с ссылкой и сгенерированным паролем. Пользователь проходит по ссылке, где ему сообщают, что все ок и предлагают зайти в "личные данные", чтобы сменить пароль на свой. Пользователю нет необходимости авторизироваться, он уже в системе, потому что прошел по уникальной ссылке, сгенерированной специально для него.
    Если e-mail невалидный
    То система сообщает пользователю о том, что e-mail невалидный.
    Если email уже существует в таблице зарегистрированных пользователей
    То система сообщает о том, что такой пользователь уже зарегистрирован и предлагает авторизироваться.
    Если e-mail уже существует в ордерах
    То система при регистрации подтягивает в список заказов данные из ордеров, оформленных на этот e-mail.

  Сценарий: пользователь авторизируется на сайте.
    Допустим юзер ввел e-mail
    Если e-mail валидный
    То система ждет ввода пароля
    Если e-mail невалидный
    То система сообщает пользователю о том, что e-mail невалидный.
    
    Допустим пользователь ввел пароль и нажал кнопку "войти"
    Если такого пользователя не существует в таблице зарегистрированных
    То система уведомляет его о необходимости регистрации
    Если пользователь зарегистрирован, но не прошел по подтверждающей ссылке из письма
    То система уведомляет ег о необходимости подтвердить регистрацию
    Если пароль неверный
    То система уведомляет пользователя о том, что пароль неверный
    Если пароль верный
    То система показывает ему вкладку "заказы" из личного кабинета

  Сценарий: пользователь забыл пароль и хочет его восстановить
    Допустим юзер нажал на ссылку "забыли пароль?"
    Система меняет форму входа на сайт на форму восстановления пароля

    Допустим юзер ввел e-mail и нажал на кнопку "выслать"
    Если такой e-mail есть в таблице зарегистрированных пользователей
    То система генерирует новый пароль и высылает его на e-mail и уведомляет пользователя об этом
    Если такого e-mail'а нет в таблице зарегистрированных пользователей
    То система просит посетителя зарегистрироваться (справа на этом же экране)

  Сценарий: залогиненный пользователь покупает билет.
    Допустим пользователь выбрал вариант и заполняет форму
    Система предлагает ему выбрать пассажиров, которых он сохранил в прошлом из выпадающего списка.
    И система предлагает "запомнить" данные тех пассажиров, которые он ввел.
    Данные покупателя уже внесены, но их можно отредактировать (e-mail, телефон).
    Если пользователь вводит другой e-mail покупателя
    То заказ все равно попадает в его личный кабинет
    И
    Если пользователь с этим (другим, не своим) e-mail адресом существует
    То система спросит пользователя, не хочет ли он добавить этот заказ в список заказов того, кто зарегистрирован по данному e-mail адресу

  Сценарий: незалогиненный пользователь покупает билет.
    Допустим пользователь выбрал вариант и заполняет форму
    Если он указывает в качестве e-mail адреса тот, по которому кто-то уже зарегистрирован в системе
    То система спросит его, не хочет ли он добавить этот заказ в список заказов в личном кабинете.
