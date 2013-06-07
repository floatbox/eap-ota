# encoding: utf-8

# документация колонок в таблице orders
module PaymentAttrs
  # !attribute price
  # Сумма платежа
  # :precision => 9, :scale => 2, :default => 0.0, :null => false
  # @return [Decimal]

  # !attribute last_digits_in_card
  # @deprecated
  # @see Order#last_digits_in_card
  # @return [string]

  # !attribute name_in_card
  # Имя в таком же виде как на карте
  # @return [string]

  # !attribute payment_system_name
  # @deprecated нигде не юзается
  # @return [string]

  # !attribute payment_status
  # @see Order.payment_statuses
  # @return [string]

  # !attribute transaction_id
  # @deprecated
  # @return [integer]

  # !attribute refund_transaction_id
  # @deprecated
  # @return [integer]

  # !attribute reject_reason
  # @deprecated
  # @return [string]

  # !attribute ref
  # ID платежа, сгенерированный на нашей стороне
  # @return [string]

  # !attribute their_ref
  # внешний ID платежа от платежной системы, сгенерированный на их стороне
  # @return [string]

  # !attribute charged_at
  # @deprecated
  # @return [datetime]

  # !attribute system
  # @deprecated
  # @return [string]

  # !attribute pan
  # @see Order#pan
  # @return [string]

  # !attribute type
  # тип платежной операции
  # @see Payment::ALLTYPES
  # @return [string]

  # !attribute charge_id
  # @return [integer]

  # !attribute status
  # статус обработки платежа
  # @see Payment.statuses
  # @return [string]

  # !attribute commission
  # издержки на транзакцию
  # FIXME описать лучше
  # @return [string]

  # !attribute earnings
  # Наша доля с платежа
  # :precision => 9, :scale => 2, :default => 0.0, :null => false
  # @return [decimal]

  # !attribute error_code
  # код, возвращенный платежной системой
  # FIXME? кое где в базу падают exception'ы c месседжами, логичнее было бы их держать в error_message
  # @see Payment#errro_message
  # @return [string]

  # !attribute error_message
  # Расшифровка кода, возвращенного платежной системой, в случае экспепшена - NULL
  # @see Payment#error_code
  # @return [text]

  # !attribute order_id
  # @return [integer]

  # !attribute created_at
  # @return [datetime]

  # !attribute updated_at
  # @return [datetime]

  # !attribute threeds_key
  # 
  # @return [string]

  # !attribute charged_on
  #
  # @return [date]
end

