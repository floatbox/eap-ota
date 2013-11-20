# как тестировать?
# horribly inefficient. Насколько horribly?
# нет комментариев - невозможно анализировать, как получена та или иная скидка.
class Discount::Finder

  include Commission::Fx

  # Примерная реализация of real world data. Как тестировать?
  # TODO передавать сюда же контекст, для специальных правил для партнеров и админов?
  def find!(rec, opts={})
    # принимает локальное время. Всегда ли сервер по московскому времени?
    # писать от будущего в прошлое
    commission = rec.commission
    rule = case
      when Time.new(2013, 11, 18,  0, 0).past?

        # Женя:
        # для правил ДТТ увеличиваем скидку = 100% комиссии+3,5%
        # для комиссионных правил АЦ скидка=30%
        case commission.ticketing_method
        when 'downtown'
          netto_discount(commission, '3.5%')
        when 'aviacenter', 'direct'
          scaled_discount(commission, 0.3)
        end

      when Time.new(2013, 11, 16,  0, 0).past?

        # Коля:
        # для ДТТ - скидки вообще убираем
        # для АЦ комиссионных - тоже убираем
        # для некомиссионных - надбавка 100 р. с билета.
        if no_commission?(commission)
          Discount::Rule.new(discount: Fx('0'), our_markup: Fx('100'))
        else
          zero
        end

      when Time.new(2013, 11, 15,  0, 0).past?

        # Женя: для правил ДТТ скидка=70% комиссии
        case commission.ticketing_method
        when 'downtown'
          scaled_commission(commission, 0.7)
        else
          zero
        end

      when Time.new(2013, 11, 11,  19, 30).past?

        # Коля: надо сделать 3.5%
        netto_discount(commission, '3.5%')
      end

    rec.discount_rule = rule
  end

  private

  def netto_discount(commission, discount)
    Discount::Rule.new(
      discount: (commission.subagent.extract('%') + Fx(discount)).round(2),
      our_markup: Fx('0')
    )
  end

  def scaled_discount(commission, multiplier)
    Discount::Rule.new(
      discount: (commission.subagent.extract('%') * multiplier).round(2),
      our_markup: Fx('0')
    )
  end

  def zero
    Discount::Rule.new(
      discount: Fx('0'),
      our_markup: Fx('0')
    )
  end

  def no_commission?(commission)
    commission.subagent.extract("%") == Fx('0')
  end
end
