# encoding: utf-8
module IncomeDistribution

  # метод платежа
  def scheme_payture
    price_with_payment_commission * Payture.pcnt
  end

  def scheme_cache
    price_with_payment_commission * Payture.pcnt
  end

  # метод обилечивания
  # 'тариф+таксы' -cумма субагентской комиссии +сбор авиацентра в рублях +cбор за бланки
  def scheme_aviacenter
    # + price_blanks
    price_fare + price_tax - price_subagent + price_consolidator + price_blanks
  end

  def scheme_direct
    price_fare + price_tax - price_agent
  end

  def income
    price_with_payment_commission - income_payment_gateways - income_suppliers
  end

  def income_payment_gateways
    if payment_type == 'card'
      scheme_payture
    else
      0
    end
  end

  def income_suppliers
    if commission_ticketing_method == 'aviacenter'
      scheme_aviacenter
    else
      scheme_direct
    end
  end

end
