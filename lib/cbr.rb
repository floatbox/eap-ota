module CBR
  class << self
    include LayeredExchange
    def exchanges
      @exchanges ||= {}
    end

    def exchange_on(date)
      # Параметр-блок задает метод округления
      exchanges[date] ||=
        ExchangeWithFallback.new(
          InverseRatesFor.new({from: 'RUB'},
            RatesUpdatedWithFallback.new(
              ActiveRecordRates.new(CurrencyRate.where(date: date, bank: 'cbr')),
              LazyRates.new { CentralBankOfRussia.update_rates(date) } ))){|p| p.round}
    end
  end
end
