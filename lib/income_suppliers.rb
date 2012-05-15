# encoding: utf-8
module IncomeSuppliers
  # included в Order, Ticket и Recommendation

  # прибыль поставщика
  # требует заполненных price_* полей и селектор commission_ticketing_method
  # TODO определить поведение для nil в одном из price_*
  def income_suppliers
    # пока штрафы бывают только у билетов
    penalty = (respond_to?(:price_penalty) ? price_penalty : 0)

    case commission_ticketing_method
    when 'aviacenter', 'downtown'
      # 'тариф+таксы' -cумма субагентской комиссии +сбор авиацентра в рублях +cбор за бланки
      price_fare + price_tax + penalty - price_subagent + price_consolidator + price_blanks
    else
      price_fare + price_tax + penalty - price_agent
    end
  end

end
