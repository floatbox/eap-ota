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
            AmadeusBank.new(date) ))
    end

    def euro_rate
      exchange_on.exchange_with('1 EUR'.to_money, "RUB").to_f
    end

  end

  class AmadeusBank < Money::Bank::VariableExchange
    def initialize(date = Date.today)
      @date = date
    end

    def get_rate(from, to)
      rate = Amadeus.booking.conversion_rate(Money::Currency.wrap(from).to_s, Money::Currency.wrap(to).to_s, @date).round(2)
    end
  end

end
