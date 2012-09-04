module CBR
  class << self
    include LayeredExchange
    def exchanges
      @exchanges ||= {}
    end

    def exchange_on(date)
      exchanges[date] ||=
        ExchangeWithFallback.new(
          InverseRatesFor.new({from: 'RUB'},
            RatesUpdatedWithFallback.new(
              ActiveRecordRates.new(CurrencyRate.where(date: date, bank: 'cbr')),
              LazyRates.new { CentralBankOfRussia.new.update_rates(date) } )))
    end

    def exchange_on(date)
      exchanges[date] ||=
        ExchangeWithFallback.new(
          SynchronizedRates.new(
            DoubleConvertThrough.new('RUB'),
              InverseRatesFor.new({from: 'RUB'},
                RatesUpdatedWithFallback.new(
                  ActiveRecordRates.new(CurrencyRate.where(date: date, bank: 'cbr')),
                  LazyRates.new { CentralBankOfRussia.new.update_rates(date) } )))
    end
  end
end
