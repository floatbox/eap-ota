module Amadeus::Rate
 include LayeredExchange
  def self.exchanges
    @exchanges ||= {}
  end

  def self.exchange_on(date=Date.today)
    exchanges[date] ||=
      ExchangeWithFallback.new(
        InverseRatesFor.new({from: 'RUB'},
          RatesUpdatedWithFallback.new(
            ActiveRecordRates.new(CurrencyRate.where(date: date, bank: 'amadeus')),
            LazyRates.new { AmadeusBank.new.update_rates } )))
  end

  class AmadeusBank < Money::Bank::VariableExchange
    def update_rates
      rate = Amadeus.booking.conversion_rate('EUR').round(2)
      add_rate 'EUR', 'RUB', rate
      add_rate 'RUB', 'EUR', 1/rate
      self
    end
  end
end
