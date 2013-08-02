module CBR
  class << self
    include LayeredExchange
    def exchanges
      @exchanges ||= {}
    end

    class LoggingCBR < CentralBankOfRussia

      def update_rates(date)
        Rails.logger.info "Getting CBR rates for #{date}"
        super
      end

    end

    def exchange_on(date)
      # Параметр-блок задает метод округления
      exchanges[date] ||=
        ExchangeWithFallback.new(
          InverseRatesFor.new({from: 'RUB'},
            RatesUpdatedWithFallback.new(
              ActiveRecordRates.new(CurrencyRate.where(date: date, bank: 'cbr')),
              LazyRates.new { LoggingCBR.new.update_rates(date) } ))){|p| p.round}
    end

    def preload_rate
      date = Time.now.hour > 16 ? Date.today + 1.day : Date.today
      CBR.exchange_on(date).exchange_with("1 USD".to_money, "RUB")
    rescue Exception
      with_warning
    end
  end
end
