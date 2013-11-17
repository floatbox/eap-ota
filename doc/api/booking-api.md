## Версия v1.2

## Проверка мест

### Запрос
В поиске у каждого варианта есть параметр - recommendation.

Его нужно передавать в качестве GET параметра в /api/v1/preliminary_booking

Необязательные параметры: adults, children и infants (по умолчанию равны 1,0,0)

Пример url для запроса:

* чтобы получить в ответ xml: https://eviterra.com/api/preliminary_booking.xml?recommendation=amadeus.LO.SS.MM.88.LO678SVOWAW151212-LO335WAWCDG161212&adults=2&children=1&infants=1
* json: https://eviterra.com/api/preliminary_booking.json?recommendation=amadeus.LO.SS.MM.88.LO678SVOWAW151212-LO335WAWCDG161212&adults=2&children=1&infants=1

### Ответ
number -  нужен будет при создании бронирования

info.prices - цены, соответствуют ценам в обычной форме покупки билета

info.rules - правила тарифа

info.booking_classes - новые классы бронирования

## Покупка билета
url для запроса: https://eviterra.com/api/v1/pay

Необходимо отправлять POST запрос со такими же параметрами, как и при обычтом запросе через web.

### Пример параметров:
 
person_attributes[0][last_name]:ADULT

person_attributes[0][first_name]:ALEX

person_attributes[0][sex]:m

person_attributes[0][birthday_day]:12

person_attributes[0][birthday_month]:12

person_attributes[0][birthday_year]:1980

person_attributes[0][nationality_code]:RUS

person_attributes[0][passport]:1232323232

person_attributes[0][bonus_present]:1

person_attributes[0][document_noexpiration]:1

person_attributes[0][bonuscard_type]:AF

person_attributes[0][bonuscard_number]:54543445

person_attributes[1][last_name]:INFANT

person_attributes[1][first_name]:IVAN

person_attributes[1][sex]:m

person_attributes[1][birthday_day]:12

person_attributes[1][birthday_month]:12

person_attributes[1][birthday_year]:2011

person_attributes[1][nationality_code]:RUS

person_attributes[1][passport]:343434556

person_attributes[1][document_expiration_day]:12

person_attributes[1][document_expiration_month]:12

person_attributes[1][document_expiration_year]:2019

person_attributes[1][bonuscard_type]:AF

person_attributes[1][bonuscard_number]:

order[number]:50cf3614cbe7f96d79000019

order[email]:test@example.com

order[phone]:+79998887766

order[payment_type]:card

order[delivery]:

card[number]:4111  1111  1111  1112

card[name]:MR CARDHOLDER

card[month]:12

card[year_short]:15

card[verification_value]:123


Ответ содержит следующие поля:

success:
* true - бронирование созданно успешно
* false - бронирование не созданно
* threeds - требуется 3ds авторизация

reason - причина того, что бронирование не было создано:
* unable_to_sell - забронировать не возможно по внешним (не связанным с данными запроса) причинам.
* price_changed - цена данного предложения изменилась, необходимо подтвердить новую цену (нужно послать точно такой же запрос еще один раз), дополнительная информация в поле info
* invalid_data - данные в запросе не валидны, дополнительная информация в поле errors

pnr_number - содержит номер pnr в случае успешного создания брони.

info, errors, payment - содержат дополнительную информацию о причинах неуспешного создания бронирования.

threeds_url: URL, на который необходимо отправить POST запрос с параметрами, указанными в поле threeds_params, для подтверждения платежа
