# language: ru
Функционал: Поиск рейсов

  @javascript @wip
  Сценарий: пользователь ищет рейс Москва - Рим и обратно в прайсере
    Допустим я нахожусь на pricer
    Если я заполняю следующие поля:
    |Откуда       | москва|
    |Куда         | рим   |
    |дата отправления | 300710|
    |дата возвращения | 080810|
    И я ставлю галочку "и обратно"
    И я нажимаю на кнопку "Найти"
    То я должен увидеть "Шереметьево"

  @javascript
  Сценарий: пользователь ищет рейс москва и обратно на главной странице и бронирует его
    Допустим я нахожусь на главной
    То в поле "Откуда" написано "Москва"
    Если я ввожу "берл" в поле "Куда"
    То я должен увидеть "Берлин" внутри ".autocomplete-list"
    И я должен увидеть "Германия" внутри ".autocomplete-list"
    Если я в комплитере кликаю по варианту "Берл" "ин"
    То в поле "Куда" написано "Берлин"
    Если я в календаре кликаю по дню через 5 дней
    И затем я в календаре кликаю по дню через 10 дней
    И нажимаю на "Искать"
    То я должен увидеть "Ищем для вас лучшие предложения"
    Если я жду 10 секунд
    То я должен увидеть "Купить"
    #И в заголовке выдачи содержится "Из Москвы в Берлин и обратно" c интервалом через 5 дней - через 10 дней
    Если я нажимаю кнопку "Купить" внутри варианта 2
    То я должен оказаться на странице pnr_form
    Если я заполняю следующие поля:
    |Фамилия |             Ivanov|
    |Имя     |               Ivan|
    |Телефон |           12345678|
    |email   |  email@example.com|
    И нажимаю "Купить"
    То я должен увидеть страницу pnr
    И должно быть отправлено письмо на адрес "email@example.com"

  @javascript
  Сценарий: подсветка дат и очистка дат в календаре
    Допустим я нахожусь на главной
    Если я в календаре кликаю по дню через 5 дней
    То дата через 5 дней подсвечивается
    И затем я в календаре кликаю по дню через 10 дней
    То дата через 10 дней выделяются цветом
    И дата через 5 дней выделяются цветом
    И интервал через 5 дней - через 10 дней подсвечивается цветом
    Если я нажимаю кнопку "Сбросить"
    То в календере не будет выбранных дат

