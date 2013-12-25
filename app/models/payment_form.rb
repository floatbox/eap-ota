# encoding: utf-8
# попытка объединить валидацию всех методов платежа
class PaymentForm
  include KeyValueInit
  include ActiveModel::Validations
  attr_accessor :type
  attr_accessor :amount
  attr_reader :card

  def card= attrs
    @card = CreditCard.new(attrs)
  end

  def amount= value
    @amount = value.to_f
  end
end
