module CBR
  class << self
    def usd(amount=1.0)
      course = Conf.cbr.usd[Date.today] || Conf.cbr.usd.max[1]
      (amount * course).round(2)
    end

    # bank.exchange(money, "USD")
    def bank date
      bank = VariableExchangeBank.new.add_rate("RUB", "USD", Conf.cbr.usd[date])
      bank.add_rate("USD", "RUB", (1/Conf.cbr.usd[date]))
      bank
    end
  end
end
