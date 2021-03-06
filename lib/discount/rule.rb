# encoding: utf-8
#
# скидочное правило.
class Discount::Rule

  extend Commission::Attrs
  include KeyValueInit
  include Commission::Fx
  include CallerAddress
  extend CallerAddress

  # формула для расчета нашей надбавки к стоимости
  # @return [Commission::Formula]
  has_commission_attrs :our_markup

  # формула для расчета скидки, считается на основе тарифа
  # @return [Commission::Formula]
  has_commission_attrs :discount

  attr_accessor :source, :meta

  def initialize(*)
    @discount = Fx(0)
    @our_markup = Fx(0)
    @source ||= caller_address
    @meta ||= 'direct'
    super
  end

  def self.netto(commission, discount)
    new(
      discount: (commission.subagent.extract('%') + Commission::Formula.new(discount)).round(2),
      our_markup: '0',
      source: caller_address,
      meta: "netto discount #{discount.inspect} of #{commission.subagent.extract('%').inspect}"
    )
  end

  def self.scaled(commission, multiplier)
    new(
      discount: (commission.subagent.extract('%') * multiplier).round(2),
      our_markup: '0',
      source: caller_address,
      meta: "scaled discount #{multiplier} * #{commission.subagent.extract('%').inspect}"
    )
  end

  def self.zero
    new # инициализатор делает пустое правило by default
  end

  # учитывая, что у нас обычно ЛИБО скидка, ЛИБО надбавка, делаю шорткат
  def total= commission
    if commission < Fx(0)
      @discount = -commission
      @our_markup = Fx(0)
    else
      @discount = Fx(0)
      @our_markup = commission
    end
  end

  def inspect
    "<Discount::Rule discount: #{discount.inspect} markup: #{our_markup.inspect} at #{source} (#{meta})"
  end

end
