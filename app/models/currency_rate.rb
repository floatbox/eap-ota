# encoding: utf-8
class CurrencyRate < ActiveRecord::Base
  #   string   "from"
  #   string   "to"
  #   string   "bank"
  #   float    "rate"
  #   date     "date"

  scope :amadeus, where(bank: 'amadeus')
  scope :cbr, where(bank: 'cbr')

  def self.currencies
    # FIXME работает только на мускле. mysql2 драйвер почему-то не эскейпит "from"
    (uniq.pluck("`from`") + uniq.pluck("`to`")).uniq.sort
  end

end
