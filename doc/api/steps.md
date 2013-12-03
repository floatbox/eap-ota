## морда

### validate

```yaml
GET: 'http://eviterra.com/pricer/validate/'
Action: 'PricerController#validate'
Params:
  search:
    segments:
      - from: 'MOW'
        to: 'NYC'
        # FIXME почему-то такой формат
        date: 'DDMMYY'
    people_count:
      adults: '1'
      children: '0'
      infants: '1'
    cabin: 'Y'

Returns:
  json: ...
```

зачем-то второй раз

```yaml
GET: 'http://eviterra.com/pricer/validate/'
Action: 'PricerController#validate'
Params:
  query_key: 'MOW-NYC-15Jun-2adults-business'

Returns:
  json:
```


## мордопоиск

```yaml
GET: 'https://eviterra.com/pricer/'
Action: 'PricerController#pricer'
Params:
  query_key: 'MOW-NYC-15Jun-2adults-business'
Returns:
  html:
    '@recommendation_set': RecommendationSet рекомендаций
    ...
```

### проверка мест

```yaml
GET: 'https://eviterra.com/booking/preliminary_booking'
Action: 'BookingController#preliminary_booking'
Params:
  query_key: 'KJA-OGZ-22Nov-27Nov'
  recommendation: 'amadeus.UT.17909.HHHH.MMMM.9999.UT572KJAVKO221113-UT395VKOOGZ221113.UT396OGZVKO271113-UT571VKOKJA271113'
Returns: ...
```

### форма бронирования

```yaml
GET: 'https://eviterra.com/booking/'
Params:
  number: '528c24803457fb6cf7000004'
Returns: ...
```

### пересчет цены

```yaml
# когда дергается?
POST: "https://eviterra.com/booking/recalculate_price"
Action: 'BookingController#recalculate_price'
Params: такие же как у pay
Returns: ...
```

### бронирование+платеж

```yaml
POST: "https://eviterra.com/booking/pay"
Action: 'BookingController#pay'
Params:
  order:
    number: 528d74653457fb6fb800001d
    email: Kimds2009@mail.ru
    phone: '+79244904256'
    payment_type: card
  person_attributes:
    '0':
      last_name: KIM
      first_name: DMITRII
      sex: m
      birthday:
        day: '13'
        month: '01'
        year: '1985'
      nationality_code: RUS
      passport: '6411790821'
      document_noexpiration: '1'
      bonuscard_type: 'AF'
      bonuscard_number: '123412234'
  card:
    number:
    ...

Returns:
  ...
```


## обычный апи

### апи поиск

```yaml
GET: '/avia/v1/variants.xml'
Action: 'PricerController#api'
Params:
  from: SVX
  to: EDI
  date1: 2014-01-04
  date2: 2014-01-08
  adults: 1
  children: 0
  infants: 0
  partner: skyscanner
returns:
  xml:
    @recommendation_set
```


### морда лэндинг

```yaml
GET: 'https://eviterra.com/api/booking/SGC-OVB-15Sep-30Sep'
Action: 'BookingController#api_booking'
Params:
  query_key: (как часть урла)
Returns:
  html:
```

### морда проверки мест

? чем-то отличается от стандартной?

## скайсканнер

апи_поиск:

апи_проверка_мест:

форма_бронирования:

## связной

апи_поиск:

апи_проверка_мест:

апи_бронирование:

апи_платеж:

куча вопросов, как работает платеж в рапиде?

## армяне

### апи поиск

стандартный

### апи создание заказа

```yaml
POST: 'https://api.eviterra.com/v2/orders'
Action:
Params:
  - код рекоммендации
  - количество пассажиров
  recommendation:
  adults:
  children:
  infants:
Returns:
  - линк на заказ
  - цена
  - расписание (с классами и подклассами)
  - правила тарифа?
  json:
    link: 'https://api.eviterra.com/v2/orders/:id'
```

### апи бронирование

```yaml
POST: 'https://api.eviterra.com/v2/orders/:id'
Action:
Params:
  данные покупателя
  persons:
  email:
  phone:
Returns:
  json:
```

### апи платеж

```yaml
POST: 'https://api.eviterra.com/v2/orders/:id'
Action:
Params:
  json:
    payment:
      type: "invoice"
      amount: "RUB 123.34"
Returns:
  json:
```

### апи состояние

```yaml
GET: 'https://api.eviterra.com/v2/orders/:id'
Returns:
  json:
```
