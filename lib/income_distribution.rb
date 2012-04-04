# encoding: utf-8
module IncomeDistribution

  def income
    @income ||= income_earnings - income_suppliers
  end

  def income_payment_gateways
    secured_payments.to_a.sum(&:income_payment_gateways)
  end

  def income_earnings
    secured_payments.to_a.sum(&:earnings)
  end

  # FIXME применяется для order-а, что неверно. Билеты могут быть выписаны в разных офисах
  def income_suppliers
    case commission_ticketing_method
    when 'aviacenter', 'downtown'
      scheme_subagent
    else
      scheme_direct
    end
  end

  # метод обилечивания
  # 'тариф+таксы' -cумма субагентской комиссии +сбор авиацентра в рублях +cбор за бланки
  def scheme_subagent
    price_fare + price_tax - price_subagent + price_consolidator + price_blanks
  end

  def scheme_direct
    price_fare + price_tax - price_agent
  end

end
