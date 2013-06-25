# encoding: utf-8

# класс для регулярно повторяющихся вещей, которое лень указывать в каждой комиссии
# FIXME а не вфигачить ли сюда еще и скидки?
class Commission::Correctors

  def self.apply(rule, kind)
    return unless kind
    new(rule).send kind
  end

  def initialize(rule)
    @rule = rule
  end

  attr :rule

  # авиацентр берет по два (обычно) дополнительных процента, если их прибыль слишком мала.
  # однако определяет применение правила по субагентской комиссии. если они нам дают 5 или менее рублей за билет
  # (они вынуждены давать хоть что-то по закону), то с клиента дополнительно взимается два (или 1 процент)
  # делаем обратным способом - задаем процентную ставку consolidator для всех бронирований, но
  # отменяем ее, если субагентская достаточно велика, или если она выражена в процентах

  def twopercent
    if rule.no_commission || (rule.subagent.percentage? && !rule.subagent.zero?) || rule.subagent.rate > 5
      rule.consolidator = 0
    end
  end

end
