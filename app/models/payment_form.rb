# encoding: utf-8
# попытка объединить валидацию всех методов платежа
class PaymentForm
  include KeyValueInit
  include ActiveModel::Validations
  attr_accessor :type
  attr_reader :card
  def card= attrs
    @card = CreditCard.new(attrs)
  end
end
