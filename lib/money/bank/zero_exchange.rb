# "обменник", конвертирующий 0 любой валюты в 0 любой валюты, и только
require 'money'
class Money::Bank::ZeroExchange < Money::Bank::Base
  def exchange_with(from, to_currency)
    return from if same_currency?(from.currency, to_currency)
    return Money.new(0, to_currency) if from.cents.zero?
    raise Money::Bank::UnknownRate, "tried to automatically convert #{from.currency} to #{to_currency}"
  end
end
