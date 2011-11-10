# encoding: utf-8
module IncomeDistribution

  # метод платежа
  def scheme_payture
    price_with_payment_commission * Payture::PCNT
  end

  def scheme_cache
    price_with_payment_commission * Payture::PCNT
  end

  # метод обилечивания
  # 'тариф+таксы' -cумма субагентской комиссии +сбор авиацентра в рублях +cбор за бланки
  # FIXME price_share переделать в price_subagent
  def scheme_aviacenter
    # + price_blanks
    price_fare + price_tax - price_subagent + price_consolidator + price_blanks
  end

  def scheme_direct
    0
    # price_fare + price_tax - price_agent
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
    scheme_aviacenter
  end

end
