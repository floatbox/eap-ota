# encoding: utf-8
module IncomeDistribution

  def income
    income_earnings - income_suppliers
  end

  def income_payment_gateways
    payments.secured.to_a.sum(&:income_payment_gateways)
  end

  def income_earnings
    payments.secured.to_a.sum(&:earnings)
  end

  def income_suppliers
    if commission_ticketing_method == 'aviacenter'
      scheme_aviacenter
    else
      scheme_direct
    end
  end

  # метод обилечивания
  # 'тариф+таксы' -cумма субагентской комиссии +сбор авиацентра в рублях +cбор за бланки
  def scheme_aviacenter
    price_fare + price_tax - price_subagent + price_consolidator + price_blanks
  end

  def scheme_direct
    price_fare + price_tax - price_agent
  end

end
