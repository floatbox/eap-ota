## Версия v1.3

## Проверка мест

### Запрос

В поиске у каждого варианта есть параметр - recommendation.

Его нужно передавать в качестве POST параметра в https://api.eviterra.com/v1/orders

Необязательные параметры: adults, children и infants (по умолчанию равны 1,0,0)

### Пример параметров: (application/x-www-form-urlencoded)

```
recommendation=amadeus.LO.SS.MM.88.LO678SVOWAW151212-LO335WAWCDG161212
adults=2
children=1
infants=1
```

### Ответ

json:
number -  нужен будет при создании бронирования

info.prices - цены, соответствуют ценам в обычной форме покупки билета

info.rules - правила тарифа

info.booking_classes - новые классы бронирования

## Бронирование и оплата

url для запроса: https://api.eviterra.com/v1/orders/<number>

Необходимо отправлять POST запрос со такими же параметрами, как и при обычтом запросе через web.

### Пример параметров: (application/x-www-form-urlencoded)

```
order[email]=test@example.com
order[phone]=+79998887766
order[payment_type]=cash
order[persons][0][last_name]=ADULT
order[persons][0][first_name]=ALEX
order[persons][0][sex]=m
order[persons][0][birthday]=1980-12-20
order[persons][0][nationality_code]=RUS
order[persons][0][passport]=1232323232
order[persons][0][bonus_present]=1
order[persons][0][document_noexpiration]=1
order[persons][0][bonuscard_type]=AF
order[persons][0][bonuscard_number]=54543445
order[persons][1][last_name]=INFANT
order[persons][1][first_name]=IVAN
order[persons][1][sex]=m
order[persons][1][birthday]=2011-01-13
order[persons][1][nationality_code]=RUS
order[persons][1][passport]=343434556
order[persons][1][document_expiration]=2019-12-01
order[persons][1][bonuscard_type]=AF
order[persons][1][bonuscard_number]=
```

### Ответ содержит следующие поля:

success:
* true - бронирование созданно успешно
* false - бронирование не созданно
* threeds - требуется 3ds авторизация (для карт)

reason - причина того, что бронирование не было создано:
* unable_to_sell - забронировать не возможно по внешним (не связанным с данными запроса) причинам.
* price_changed - цена данного предложения изменилась, необходимо подтвердить новую цену (нужно послать точно такой же запрос еще один раз), дополнительная информация в поле info
* invalid_data - данные в запросе не валидны, дополнительная информация в поле errors

pnr_number - содержит номер pnr в случае успешного создания брони.

info, errors, payment - содержат дополнительную информацию о причинах неуспешного создания бронирования.

threeds_url: URL, на который необходимо отправить POST запрос с параметрами, указанными в поле threeds_params, для подтверждения платежа
