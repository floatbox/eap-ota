# как-то так:
#
# include LayeredExchange
# date = Date.today
# bank = ExchangeWithFallback.new(
#   ReverseRateIfFrom.new( 'RUB',
#     RatesUpdatedWithFallback.new(
#       ActiveRecordRates.new(CurrencyRates.where(date: date, bank: 'cbr'),
#       LazyRates.new { CentralBankOfRussia.new.update_rates(date) }
#     )
#   )
# )

module LayeredExchange

  # наследуем ради exchange_with и прочего.
  class ExchangeWithFallback < Money::VariableExchange
    def initialize(fallback_rates, &block)
      @fallback_rates = fallback_rates
      super &block
    end

    attr_reader :fallback_rates

    def get_rate(from, to)
       unless rate = super
         if rate = fallback_rates.get_rate(from, to)
           add_rate(from, to, rate)
         end
       end
       rate
    end
  end

  class RatesUpdatedWithFallback
    def initialize(main_rates, fallback_rates)
      @main_rates = main_rates
      @fallback_rates = fallback_rates
    end

    def get_rate(from, to)
       unless rate = @main_rates.get_rate(from, to)
         if rate = @fallback_rates.get_rate(from, to)
           @main_rates.add_rate(from, to, rate)
         end
       end
       rate
    end

    # нужен ли?
    def add_rate(from, to, rate)
      @main_rates.add_rate(from, to, rate)
    end
  end

  class LazyRates
    def initalize(&expensive_setup)
      @expensive_setup = expensive_setup
    end

    def get_rate(from, to)
      rates.get_rate(from, to)
    end

    def add_rate(from, to)
      rates.add_rate(from, to)
    end

    def rates
      @rates ||= @expensive_setup.call
    end
    private :rates
  end

  class ActiveRecordRates
    def initialize(scope_or_class)
      @scope = scope_or_class
    end

    def get_rate(from, to)
      if rec = @scope.where(from: from, to: to).first
        rec.rate
      end
    end

    def add_rate(from, to, rate)
      rec = @scope.where(from: from, to: to).find_or_initialize
      rec.update_attributes rate: rate
      rate
    end
  end

  # read only
  class ReverseRateIfFrom
    def initialize(from, rates)
      @from = Currency.wrap(from)
      @rates = rates
    end

    # FIXME нужен ли Currency.wrap(from)?
    def get_rate(from, to)
      if from == @from
        if rate = @rates.get_rate(to, from)
          1 / rate
        end
      else
        @rates.get_rate(from, to)
      end
    end
  end
end
