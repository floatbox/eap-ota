# encoding: utf-8
#
# скидочное правило.
class Discount::Rule

  include KeyValueInit
  extend Commission::Attrs

  # формула для расчета нашей надбавки к стоимости
  # @return [Commission::Formula]
  has_commission_attrs :our_markup

  # формула для расчета скидки, считается на основе тарифа
  # @return [Commission::Formula]
  has_commission_attrs :discount

end
