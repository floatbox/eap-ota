# encoding: utf-8

# документация колонок в таблице tickets
module TicketAttrs
  # !attribute mso_number
  # что-то для отчетности, вводится только вручную
  # @return [String]

  # !attribute cabins
  # @see Order#cabins
  # @return [String]

  # !attribute route
  # @see Order#route
  # @return [String]

  # !attribute price_tax
  # @see Order#price_tax
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_share
  # @deprecated сейчас не используется судя по всему
  # @see Order#price_share
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_consolidator_markup
  # @deprecated ?
  # @see Order#price_consolidator_markup
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_our_markup
  # @see Order#price_our_markup
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute source
  # @see Order#source
  # @return [String]

  # !attribute pnr_number
  # @see Order#pnr_number
  # @return [String]

  # !attribute number
  # @see number
  # @return [String]

  # !attribute price_penalty
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_consolidator
  # @see Order#price_consolidator
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_blanks
  # @see Order#price_blanks
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_agent
  # @see Order#price_agent
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_subagent
  # @see Order#price_subagent
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_discount
  # @see Order#price_discount
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_operational_fee
  # @see Order#price_operational_fee
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_acquiring_compensation
  # @see Order#price_acquiring_compensation
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_difference
  # @see Order#price_difference
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_fare
  # @see Order#price_fare
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute price_extra_penalty
  #
  # :precision => 9, :scale => 2, :default => 0.0,       :null => false
  # @return [Float]

  # !attribute corrected_price
  # :precision => 9, :scale => 2
  # @return [Float]

  # !attribute first_name
  # Имя клиента и обращение в верхнем регистре, разделенные пробелом
  # @return [String]

  # !attribute last_name
  # Фамилия
  # @return [String]

  # !attribute passport
  # серия и номер паспорта без пробелов
  # @return [String]

  # !attribute code
  # Серия билета, идентифицирует авиакомпанию
  # @return [String]

  # !attribute validator
  #
  # @return [String]

  # !attribute status
  # Статус билета
  # @see Ticket.statuses
  # @return [String]

  # !attribute office_id
  # Идентификатор центра выписки(контрагент)
  # @return [String]

  # !attribute ticketed_date
  # Дата выписки билета
  # @return [Date]

  # !attribute validating_carrier
  # Перевозчик, у которого выписан билет
  # @return [String]

  # !attribute kind
  # Показывает возвращен ли билет
  # @see Ticket.kinds
  # :default => "ticket"
  # @return [String]

  # !attribute parent_id
  # Номер билета-родителя
  # @return [integer]

  # !attribute comment
  # Комментарий, используемый операторами во время обмена/возврата
  # @return [text]

  # !attribute commission_subagent
  # @see Commission::Rule#subagent
  # @return [String]

  # !attribute commission_agent
  # @see Commission::Rule#agent
  # @return [String]

  # !attribute commission_consolidator
  # @see Commission::Rule#consolidator
  # @return [String]

  # !attribute commission_blanks
  # @see Commission::Rule#blanks
  # @return [String]

  # !attribute commission_discount
  # @see Commission::Rule#discount
  # @return [String]

  # !attribute commission_our_markup
  # @see Commission::Rule#our_markup
  # @return [String]

  # !attribute vat_status
  # Описывает декларируемый клиенту НДС с билет
  # :default => "unknown", :null => false
  # @return [String]

  # !attribute dept_date
  # Дата первого вылета
  # @return [Date]

  # !attribute baggage_info
  # Разделенные пробелами кодированные лимиты для провоза багажа для каждого из перелетов в билете
  # @return [String]

  # !attribute order_id
  # @return [integer]

  # !attribute created_at
  # @return [DateTime]

  # !attribute updated_at
  # @return [DateTime]
end

