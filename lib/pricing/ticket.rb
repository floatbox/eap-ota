# encoding: utf-8
module Pricing
  module Ticket
    ### formulas:
    # уже есть в базе: commission_subagent
    #
    # копируются из заказа:
    # commission_agent
    # commission_subagent
    # commission_consolidator
    # commission_blanks
    # commission_discount
    #
    ### prices:
    # price_fare
    # price_tax
    # price_agent
    # price_subagent
    # price_consolidator
    # price_blanks
    # price_discount
    #
    # price_penalty

    def price_total
      price_fare + price_tax
    end

    def price_refund
      if kind == 'refund'
        -(price_tax + price_fare + price_penalty)
      else
        0
      end
    end

    # FIXME брать реальную долю платежа
    def price_payment_commission
      price_with_payment_commission * acquiring_percentage
    end

    #FIXME это костыль, работает не всегда, нужно сделать нормально
    def price_with_payment_commission
      k = (price_tax + price_fare).to_f / (order.price_fare + order.price_tax)
      order.price_with_payment_commission * k
    end

    def price_tax_and_markup_and_payment
      price_with_payment_commission - price_fare + price_declared_discount
    end

    def price_declared_discount
      price_discount
    end

    # FIXME надо принудительно выставлять ноль, если введена пустая комиссия?
    def recalculate_commissions

      # FIXME вынести отсюда обратно в модель
      copy_commissions_from_order if new_record?

      self.price_agent = commission_agent.call(price_fare)
      self.price_subagent = commission_subagent.call(price_fare)
      self.price_consolidator = commission_consolidator.call(price_fare)
      self.price_blanks = commission_blanks.call(price_fare)
      self.price_discount = commission_discount.call(price_fare)
      true
    end

  end
end
