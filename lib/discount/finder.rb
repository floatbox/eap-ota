# как тестировать?
# horribly inefficient. Насколько horribly?
# нет комментариев - невозможно анализировать, как получена та или иная скидка.
class Discount::Finder

  include Commission::Fx

  def find!(rec, opts={})
    commission = rec.commission
    rule = Discount::Book.default_book.find_rule_for_rec rec, opts
    rec.discount_rule = rule
  end

  private

  def no_commission?(commission)
    commission.subagent.extract("%") == Fx('0')
  end
end
