## попытка сделать самый полный вариант структуры OrderSerializer#to_json

### соображения

Многие объекты могут быть заданы несколькими способами.

* уникальный id. Достаточен для передачи на сервер, если такой объект уже существует. Достаточен, чтобы указать на объект в другом месте структуры.
* параметры-ключи. Достаточно для вычисления id на сервере и для получения недостающей информации из амадеуса или еще где.
* полное представление - с вложенными объектами, с локализацией, и т.п.
  подходит для скармливания шаблонам.

Для некоторых этапов достаточно частичной информации.

Например, для проверки мест достаточно просто знать примерный возраст и
количество пассажиров. При этом, имея полные данные пассажиров сразу, можно
вычислить частичную форму.

Некоторые части структуры столько раз повторяются в документе, что их можно или
даже нужно нормализовать, сделав отдельные, вложенные в документ справочники.
flights, cities, airports, countries etc. На клиенте можно будет держать
глобальный/локальный кэш. json станет более плоским, повторов будет меньше.


### итого

```yaml
order:

  id:
  weblink:
  apilink:

  email:
  phone:

  # 
  # вычисляемо из itinerary
  avia_search:
    id: 'MOW-PAR-12Jun'
    weblink:
    apilink:

  people_count:
    adults: 1
    infants: 0
    children: 0

  persons:
    - first_name: "ALEKSEY"
      last_name: "IVASHKIN"
      sex: "m"
      birthday: '1984-06-16'
      nationality_code: 'RU'
      passport: '123456789'
      document_expiration: 'YYYY-MM-DD'
      bonuscard_type: "AF"
      bonuscard_number: "1234234"
      with_seat: '...'
    - ...

  recommendations:
    - id: 'amadeus.YYY.CCC.MOWPAR32JUN...'
    - id: 'amadeus.YYY.CCC.MOWPAR32JUN...'

  itineraries:
    - id: 'amadeus.YYY.CCC.MOWPAR32JUN...'
      segments:
        flights:
          - from:
            to:
            ...
            booking_class:
            cabin:
  pnrs:
    запихать в itineraries?

  tickets:
    - number:
    - person:
      id: ...

  fare_rules:
    ...

  delivery:
    address:

  payment_options:
    - type: card
      amount: 460.34 RUB
      last_pay_time: ....
    - type: card
      amount: 12.34 USD
      last_pay_time: ....
    - type: invoice
      amount: 460.34 RUB

  payments:
    - type: card
      number: '12324xxxxxx1234'
      name:
      year:
      verification:
      amount: 12 RUB
      paid_for
        - ticket:
            id:
        - ticket:
            id:


    - type: cash
      amount: 234.34 RUB


  # надо ли обобщенный?
  booking_status: 'booked'

  # надо ли обобщенный?
  payment_status: 'authorized'

  # засунуть в prices?
  total: 234.34 RUB
  due: 12.34 RUB
```
