module CBR
  class << self
    def usd(amount=1.0)
      course = Conf.cbr.usd[Date.today] || Conf.cbr.usd.max[1]
      (amount * course).round(2)
    end

    # https://github.com/RubyMoney/money
    # bank.exchange_with(money, "USD")
    def bank date
      bank =  Money::Bank::VariableExchange.new
      bank.add_rate("RUB", "USD", Conf.cbr.usd[date])
      bank.add_rate("USD", "RUB", (1/Conf.cbr.usd[date]))
      bank
    end
  end
end
