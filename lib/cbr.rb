module CBR
  class << self
    def usd(amount=1.0)
      course = Conf.cbr.usd[Date.today] || Conf.cbr.usd.max[1]
      (amount * course).round(2)
    end
  end
end