# encoding: utf-8
module MoneyExt
  def with_currency
    to_s + ' ' + currency.to_s
  end
end

Money.send :include, MoneyExt
