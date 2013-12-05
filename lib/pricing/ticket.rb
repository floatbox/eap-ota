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
    include FeeCalculationDetails
    # есть ли расход-приход с поставщиком по билету?
    # используется для подведения счета с поставщиком
    def income_suppliers
      status == 'voided' ? 0 : super
    end

    # Цена, полученная из строки билета в бронировании
    # Пока используется только в EMD
    def price_total_raw= price_raw
      self.original_price_penalty = price_raw.to_money
    end

    def price_markup
      price_consolidator + price_our_markup + price_blanks + price_discount + price_operational_fee
    end

    def price_total
      price_fare + price_tax + price_penalty + price_markup + price_extra_penalty
    end

    def vat
      if vat_status == '18%'
        (price_with_payment_commission*18/118).round(2)
      elsif vat_status == '18%_old'
        ((price_fare + price_tax)*18/118).round(2)
      else
        0
      end
    end

    # FIXME брать реальную долю платежа
    def price_payment_commission
      case kind
      when 'ticket'
        (price_with_payment_commission * acquiring_percentage).round(2)
      when 'refund'
        price_acquiring_compensation
      end
    end

    #FIXME это костыль, работает не всегда, нужно сделать нормально
    def price_with_payment_commission
      case kind
      when 'ticket'
        return corrected_price if corrected_price
        calculated_price_with_payment_commission
      when 'refund'
        price_total + price_payment_commission
      end
    end

    def calculated_price_with_payment_commission
      all_tickets = order.tickets.where('kind = "ticket" AND status != "voided"')
      prices = [:price_fare, :price_tax, :price_consolidator, :price_blanks, :price_discount, :price_our_markup]
      corrected_total = prices.map{|p| all_tickets.sum(p)}.sum
      return 0 if corrected_total == 0
      k = prices.map{|p| send(p)}.sum.to_f / corrected_total
      (order.price_with_payment_commission * k).round(2)
    end

    def price_tax_and_markup_and_payment
      price_with_payment_commission - price_fare - price_declared_discount
    end


    def price_real# сумма всех компонентов цены кроме корректировки
      price_total + price_acquiring_compensation
    end

    def fee
      if fee_scheme == 'v2'
        price_blanks + price_consolidator + price_our_markup + price_acquiring_compensation + price_operational_fee + price_difference
      elsif fee_scheme == 'v3'
        price_blanks + price_consolidator + price_discount + price_our_markup + price_acquiring_compensation + price_difference
      else
        price_with_payment_commission - price_tax - price_fare - price_declared_discount
      end
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
        self.price_agent = commission_agent.apply(price_fare)
        self.price_subagent = commission_subagent.apply(price_fare)
        self.price_consolidator = commission_consolidator.apply(price_fare)
        self.price_blanks = commission_blanks.apply(price_fare)
        self.price_discount = -commission_discount.apply(price_fare)
        self.price_our_markup = commission_our_markup.apply(price_fare)
      when 'refund'
        # FIXME с появлением отрицательных формул могут быть интересные странности
        self.price_agent = commission_agent.percentage? ? commission_agent.apply(price_fare) : -commission_agent.apply(price_fare)
        self.price_subagent = commission_subagent.percentage? ? commission_subagent.apply(price_fare) : -commission_subagent.apply(price_fare)
      else
        raise ArgumentError, 'Unknown kind of ticket'
      end
      true
    end

  end
end
