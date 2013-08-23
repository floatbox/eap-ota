module Amadeus::Rate
  class << self
    include LayeredExchange
    def exchanges
      @exchanges ||= {}
    end

    def exchange_on(date=Date.today)
      exchanges[date] ||=
        ExchangeWithFallback.new(
          RatesUpdatedWithFallback.new(
            ActiveRecordRates.new(CurrencyRate.where(date: date, bank: 'amadeus')),
            LazyRates.new { AmadeusBank.new.update_rates(date) } ))
    end
  end

  class AmadeusBank < Money::Bank::VariableExchange
    def update_rates(date)
      raise "Date for amadeus rate is in the future!" if date.future?
      rate = Amadeus.booking.conversion_rate('EUR', date).round(2)
      add_rate 'EUR', 'RUB', rate
      rate = Amadeus.booking.conversion_rate('USD', date).round(2)
      add_rate 'USD', 'RUB', rate
      self
    end
  end
end
