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
              # Параметр-блок у CentralBankOfRussia.new задает метод округления
              LazyRates.new { CentralBankOfRussia.new{|p| p.round}.update_rates(date) } )))
    end
  end
end
