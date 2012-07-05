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
    # commission_our_markup
    #
    ### prices:
    # price_fare
    # price_tax
    # price_agent
    # price_subagent
    # price_consolidator
    # price_blanks
    # price_discount
    # price_our_markup
    #
    # price_penalty
    # price_extra_penalty

    include IncomeSuppliers
    # есть ли расход-приход с поставщиком по билету?
    # используется для подведения счета с поставщиком
    def income_suppliers
      status == 'voided' ? 0 : super
    end

    def price_markup
      price_consolidator + price_blanks - price_discount
    end

    def price_total
      price_fare + price_tax + price_penalty + price_markup + price_extra_penalty
    end

    def vat
      if vat_status == '18%'
        ((price_fare + price_tax)*18/118).round(2)
      else
        0
      end
    end

    # FIXME брать реальную долю платежа
    def price_payment_commission
      case kind
      when 'ticket'
        price_with_payment_commission * acquiring_percentage
      when 'refund'
        0
      end
    end

    #FIXME это костыль, работает не всегда, нужно сделать нормально
    def price_with_payment_commission
      case kind
      when 'ticket'
        return corrected_price if corrected_price
        all_tickets = order.tickets.where('kind = "ticket" AND status != "voided"')
        corrected_total = all_tickets.sum(:price_fare) + all_tickets.sum(:price_tax)
        return 0 if corrected_total == 0
        k = (price_tax + price_fare).to_f / corrected_total
        order.price_with_payment_commission * k
      when 'refund'
        price_total + price_payment_commission
      end
    end

    def price_tax_and_markup_and_payment
      price_with_payment_commission - price_fare + price_declared_discount
      end

    def fee
      price_with_payment_commission - price_tax - price_fare + price_declared_discount
    end

    def price_declared_discount
      price_discount
    end

    # FIXME надо принудительно выставлять ноль, если введена пустая комиссия?
    def recalculate_commissions

      # FIXME вынести отсюда обратно в модель
      copy_commissions_from_order if new_record? && (kind != 'refund')

      case kind
      when 'ticket'
        self.price_agent = commission_agent.call(price_fare)
        self.price_subagent = commission_subagent.call(price_fare)
        self.price_consolidator = commission_consolidator.call(price_fare)
        self.price_blanks = commission_blanks.call(price_fare)
        self.price_discount = commission_discount.call(price_fare)
        self.price_our_markup = commission_our_markup.call(price_fare)
      when 'refund'
        self.price_agent = commission_agent.percentage? ? commission_agent.call(price_fare) : -commission_agent.call(price_fare)
        self.price_subagent = commission_subagent.percentage? ? commission_subagent.call(price_fare) : -commission_subagent.call(price_fare)
      else
        raise ArgumentError, 'Unknown kind of ticket'
      end
      true
    end

  end
end
