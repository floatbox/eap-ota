# encoding: utf-8
module IncomeDistribution
  # included в Order и Ticket
  # требует заполненных price_* полей и селектор commission_ticketing_method

  def income_suppliers
    return 0 unless supplier_billed?
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
    price_fare + price_tax + price_penalty - price_subagent + price_consolidator + price_blanks
  end

  def scheme_direct
    price_fare + price_tax + price_penalty - price_agent
  end

end
