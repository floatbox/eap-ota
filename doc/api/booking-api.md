## Версия v1.4

### Назначение API

Позволяет партнерам создавать и оплачивать заказы (бронирование авиабилетов)
на eviterra.com. Оплаченные бронирования будут выписаны автоматически или вручную.


## Создание заказа

Создает новый заказ, при наличии мест на запрошенных рейсах. Возвращает стоимость.

### Запрос

**URL**

*  https://api.eviterra.com/v1/orders - production доступ

*  https://api-demo.eviterra.com/v1/orders - тестовый доступ

**Method** POST

**Content-type** `application/json` или `application/x-www-form-urlencoded`

### Параметры

name             | required or default  | description | example
-----------------|----------------------|-------------|--------
`recommendation` | *                    | `recommendation` из ответа api/v1/variants.xml  | amadeus.LO.SS.MM.88.LO678SVOWAW151212-LO335WAWCDG161212
`adults`         | `1`                  | полных тарифов
`children`       | `0`                  | детских тарифов с местом (до 12 лет)
`infants`        | `0`                  | детских тарифов без места (до 2 лет)

### Успешный ответ

**Status** 200 Ok

**Content-type** `application/json`

JSON path             |  description
----------------------|-------------
`success`             |  true/false, успешность операции
`order.id`            |  id заказа
`order.link`          |  URL для отправки запроса на бронирование и оплату.
`order.prices.total`  |  полная стоимость заказа, в рублях.
`order.rules`         |  правила тарифа


## Бронирование и оплата

**URL** `order.link` из ответа на предыдущий запрос.

**Method** POST

**Content-type** `application/json` или `application/x-www-form-urlencoded`

### Параметры

name                                      | required | description               | example
------------------------------------------|----------|---------------------------|--------
`order[email]`                            | *        | email покупателя          | test@example.com
`order[phone]`                            | *        | телефон покупателя        | +79998887766
`order[persons][0][last_name]`            | *        | фамилия первого пассажира | Ivanov
`order[persons][0][first_name]`           | *        | имя                       | Alexey
`order[persons][0][sex]`                  | *        | пол, m / f                | m
`order[persons][0][birthday]`             | *        |                           | 1980-12-20
`order[persons][0][nationality_code]`     | *        | ISO 3166-1 alpha-3        | RUS
`order[persons][0][passport]`             | *        |                           | 1232323232
`order[persons][0][document_expiration]`  |          |                           | 2020-12-30
`order[persons][1][last_name]`            |          | фамилия второго пассажира |
...                                       |
`order[payment_type]`                     | *        | метод оплаты              | cash

### Ответ

**Status** 200 Ok

**Content-type** `application/json`

JSON path                    | description
-----------------------------|-------------------------------
`success`                    | true/false, успешность операции
`reason`                     | причина того, что бронирование не было создано
`order.pnr_number`           | номер бронирования
`order.prices.total`         | всего к оплате, в рублях
`order.prices.fare`          | тарифы авиакомпании, в сумме
`order.prices.tax_and_markup`| налоги и сборы
`order.prices.discount`      |
`order.prices.fee`           |
`order.rules`                | правила тарифа
`errors`                     | ошибки валидации

расшифровка `reason`

* `"unable_to_sell"` забронировать невозможно по внешним (не связанным с данными запроса) причинам.
* `"price_changed"` цена данного предложения изменилась, необходимо подтвердить новую цену (нужно послать точно такой же запрос еще один раз), дополнительная информация в поле info
* `"invalid_data"` данные в запросе не валидны, дополнительная информация в поле errors

