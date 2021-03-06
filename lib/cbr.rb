module CBR

  class RateTransientError < Errors::TransientError; end

  class << self
    include LayeredExchange
    def exchanges
      @exchanges ||= {}
    end

    class LoggingCBR < CentralBankOfRussia

      def update_rates(date)
        begin
          Rails.logger.info "Getting CBR rates for #{date}"
          super
        rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, OpenURI::HTTPError, SocketError
          raise RateTransientError
        end
      end

    end

    def exchange_on(date)
      # Параметр-блок задает метод округления
      exchanges[date] ||=
        ExchangeWithFallback.new(
          InverseRatesFor.new({from: 'RUB'},
            RatesUpdatedWithFallback.new(
              ActiveRecordRates.new(CurrencyRate.where(date: date, bank: 'cbr')),
              LazyRates.new { LoggingCBR.new.update_rates(date) }
            )
          )
        ){ |p| p.round }
    end

    def preload_rate
      date = Time.now.hour > 16 ? Date.today + 1.day : Date.today
      CBR.exchange_on(date).exchange_with("1 USD".to_money, "RUB")
      true
    rescue CBR::RateTransientError => e
      fails ||= 0
      fails += 1
      Rails.logger.warn "#{e.message}: failed for #{fails} time"
      sleep(10) && retry if fails < 3
      with_warning
    rescue Exception
      with_warning
    end
  end
end
