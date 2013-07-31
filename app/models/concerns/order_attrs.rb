# encoding: utf-8

# просто документация колонок в таблице orders
module OrderAttrs

  # @!attribute email
  # может содержать несколько емейлов через запятую
  # @return [String]

  # @!attribute phone
  # используется для показа в маршрутных квитанциях, хранится в свободной форме
  # @return [String]

  # @!attribute pnr_number
  # шестизначный номер PNR в системе бронирование, не уникален, может содержать кириллицу
  # @return [String]

  # @!attribute created_at
  # @return [DateTime]

  # @!attribute updated_at
  # @return [DateTime]


  # @!attribute commission_carrier
  # @see Commission::Rule#carrier
  # IATA перевозчика
  # @return [String]

  # @!attribute commission_agent
  # агентская(обладатель договора с авиакомпанией) коммиссия
  # @see Commission::Rule#agent
  # @return [String]

  # @!attribute commission_subagent
  # @see Commission::Rule#subagent
  # @return [String]

  # @!attribute commission_agent_comments
  # @see Commission::Rule#agent_comments
  # @return [Text]            :null => false

  # @!attribute commission_subagent_comments
  # @see Commission::Rule#subagent_comments
  # @return [Text]            :null => false

  # @!attribute commission_consolidator
  #
  # @see Commission::Rule#consolidator
  # @return [String]

  # @!attribute commission_discount
  # @see Commission::Rule#discount
  # @return [String]

  # @!attribute commission_tour_code
  # @see Commission::Rule#tour_code
  # @return [String]

  # @!attribute commission_designator
  # @see Commission::Rule#designator
  # @return [String]

  # @!attribute commission_ticketing_method
  # @see Commission::Rule#ticketing_method
  # @return [String]          :default => "",       :null => false

  # @!attribute commission_our_markup
  # @see Commission::Rule#our_markup
  # @return [String]

  # @!attribute commission_blanks
  # @see Commission::Rule#blanks
  # @return [String]

  # @!attribute price_share
  # @deprecated сейчас не используется судя по всему

  # @!attribute price_our_markup
  # надбавка к тарифу, в процентах или фиксированной сумме с билета
  # @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute price_with_payment_commission
  # @see Pricing::Recommendation#price_with_payment_commission
  # @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute price_fare
  # тариф, расчитывается как totalFareAmount - totalTaxAmount из выдачи рекомендации амадеуса
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_consolidator_markup
  # @deprecated ?
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_difference
  # корректировка цены - разница между окончательной ценой при расчете и реальной ценой билета
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_tax
  # Налоги и сборы на билет
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_discount
  # Компенсация от тарифа (тариф * формула скидки), имеет отрицательное значение
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_consolidator
  # Надбавка консолидатору в случае, когда агентская комиссия низкая (1-2% авиацентра)
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_blanks
  # Надбавка за бланки билета в сирене
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_agent
  # Сумма, которую получает агент от авиакомпании с проданных билетов
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_subagent
  # Сумма, которую получает субагент от агента с проданного билета
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_operational_fee
  # Сумма сбора за операции обмена/возврата
  # @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute price_acquiring_compensation
  # Сумма, добавляемая к цене, для компенсации эквайринга
  # @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute order_id
  # @return [String]

  # @!attribute full_info
  # Текстовые данные содержащие информацию о пассажирах
  # @return [String]

  # @!attribute payment_status
  # Статус оплаты
  # @see Order.payment_statuses
  # @return [String]          :default => "new"

  # @!attribute ticket_status
  # @see Order.ticket_statuses
  # @return [String]          :default => "booked"

  # @!attribute name_in_card
  # Имя на карте плательщика
  # @return [String]

  # @!attribute last_digits_in_card
  # @deprecated походу уже не используется
  # Номер карты с "замазанными" центральными цифрами
  # @return [String]

  # @!attribute commission_agent_comments
  #   @return [Text]

  # @!attribute commission_subagent_comments
  #   @return [Text]

  # @!attribute source
  # Название GDS, в которой сделан заказ
  # @return [String]          :default => "other"

  # @!attribute sirena_lead_pass
  # Фамилия первого пассажира в брони, используется только в Сирене
  # @return [String]

  # @!attribute code
  # Сгенерированный для коротких ссылок хеш на оплату/доплату
  # @return [String]

  # @!attribute description
  # Поле, которое показывается в ссылках на оплату/доплату
  # @return [String]

  # @!attribute last_tkt_date
  # Дата до которой нужно обилетить бронь, влияет на способы оплаты/доставки(по крайней мере в OrderForm)
  # @return [Date]

  # @!attribute ticketed_date
  # Дата, когда бронь была обилечена
  # @return [Date]

  # @!attribute delivery
  # Адрес доставки 
  # @return [Text] ('')

  # @!attribute payment_type
  # Тип оплаты
  # @see Order.payment_types
  # @return [String]

  # @!attribute last_pay_time
  # Время до которого клиент должен оплатить заказ
  # @return [DateTime]

  # @!attribute cash_payment_markup
  # @deprecated
  # @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute cabins
  # Класс обслуживания, может содержать несколько через запятую
  # @return [String]

  # @!attribute offline_booking
  # флаг, означающий что бронирование сделано вручную, а не автоматически
  # @return [Boolean]         :default => false,    :null => false

  # @!attribute email_status
  # Статус отправки письма
  # @return [String]          :default => "",       :null => false

  # @!attribute route
  # Список аэропортов, через которые проходит маршрут(разделены '; ')
  # @return [String]

  # @!attribute departure_date
  # Дата первого вылета
  # @return [Date]

  # @!attribute blank_count
  # Предполагаемое количество билетов в брони(для амадеуса всегда равно количеству пассажирова, для сирены - не всегда)
  # @return [Fixnum]

  # @!attribute partner
  # Источник траффика, по которому пришел клиент, сделавший заказ
  # @return [String]

  # @!attribute has_refunds
  # флаг - были ли возвраты
  # @return [Boolean]                                    :default => false,    :null => false

  # @!attribute pricing_method
  # Учетная политика, влияет на расчет эквайринга
  # @see Order.pricing_methods
  # @return [String]                                     :default => "",       :null => false

  # @!attribute fix_price
  # Флаг, означающий что сумма, взятая с клиента зафиксирована и не может измениться. Нужен для того, чтобы понять, нужно ли пересчитывать итоговую цену заказа
  # @return [Boolean]         :default => false,    :null => false

  # @!attribute old_booking
  # флаг, позволяющий запретить пересчет, используется в update_prices_from_tickets
  # @return [Boolean]         :default => false,    :null => false

  # @!attribute pan
  # Номер карты с "замазанными" центральными цифрами
  # @return [String]

  # @!attribute marker
  # Идентификатор клиента для партнера
  # @return [String]

  # @!attribute parent_pnr_number
  # Родительский PNR
  # @return [String]

  # @!attribute stored_income
  # Предполагамый доход
  # @see Pricing::Order#income
  # @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute stored_balance
  # Предполагамый доход
  # @see Pricing::Order#income
  # @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute customer_id
  # Идентификатор клиента (для модели Customer)
  # @return [Fixnum]

  # @!attribute fee_scheme
  # Схема расчета сервисного сбора
  # @see Order.fee_scheme
  # @return [String]        :default => ""

end
