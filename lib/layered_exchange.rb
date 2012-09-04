# example
#   date = Date.today
#   ExchangeWithFallback.new(
#     SynchronizedRates.new(
#       DoubleConvertThrough.new('RUB'),
#         InverseRatesFor.new({from: 'RUB'},
#           RatesUpdatedWithFallback.new(
#             ActiveRecordRates.new(CurrencyRate.where(date: date, bank: 'cbr')),
#             LazyRates.new { CentralBankOfRussia.new.update_rates(date) } )))

module LayeredExchange

  # наследуем ради exchange_with и прочего.
  class ExchangeWithFallback < Money::Bank::VariableExchange
    def initialize(fallback_rates, &block)
      @fallback_rates = fallback_rates
      super &block
    end

    attr_reader :fallback_rates

    def get_rate(from, to)
       unless rate = super
         if rate = fallback_rates.get_rate(Money::Currency.wrap(from), Money::Currency.wrap(to))
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
    def initialize(&expensive_setup)
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
      if rec = @scope.where(from: from.to_s, to: to.to_s).first
        rec.rate
      end
    end

    def add_rate(from, to, rate)
      rec = @scope.where(from: from.to_s, to: to.to_s).first_or_initialize
      rec.update_attributes rate: rate
      rate
    end
  end

  # read only
  class InverseRatesFor
    def initialize(to_or_from, rates)
      if to_or_from[:from]
        @reverse_from = Money::Currency.wrap(to_or_from[:from])
      elsif to_or_from[:to]
        @reverse_to = Money::Currency.wrap(to_or_from[:to])
      end
      @rates = rates
    end

    def get_rate(from, to)
      if @reverse_from == from || @reverse_to == to
        if rate = @rates.get_rate(to, from)
          1 / rate
        end
      else
        @rates.get_rate(from, to)
      end
    end
  end

  # read only
  class DoubleConversionThrough
    def initialize(base, rates)
      @base = Money::Currency.wrap(base)
      @rates = rates
    end

    def get_rate(from, to)
      if from != @base && to != @base
        rate1 = @rates.get_rate(from, @base) or return
        rate2 = @rates.get_rate(@base, to) or return
        rate1 * rate2
      else
        @rates.get_rate(from, to)
      end
    end
  end

  # каргокульт. для многозадачности!
  class SynchronizedRates
    def initialize(rates)
      @mutex = Mutex.new
      @rates = rates
    end

    def get_rate(from, to)
      @mutex.synchronize { @rates.get_rate(from, to) }
    end

    def add_rate(from, to, rate)
      @mutex.synchronize { @rates.add_rate(from, to, rate) }
    end
  end
end
