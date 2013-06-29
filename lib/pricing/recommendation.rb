module Pricing
  module Recommendation

    attr_accessor :price_fare, :price_tax, :blank_count

    delegate :subagent, :agent, :consolidator, :blanks, :discount, :our_markup, :ticketing_method,
      :to => :commission, :prefix => :commission, :allow_nil => true

    include IncomeSuppliers

    # FIXME работает для текущей схемы, считает что мы эквайринг не берем себе в общем случае
    def income
      @income if @income
      discount_correction = [0, price_payment + price_discount].max
      price_our_share = commission && commission.ticketing_method == 'direct' ? price_agent : price_subagent
      @income = price_our_share * 100.0/118.0 + price_discount - discount_correction * 0.18
    end

    # составные части стоимости

    # сумма, которая придет нам от платежного шлюза
    def price_total
      price_fare + price_tax + price_markup
    end

    def price_fare_and_tax
      price_fare + price_tax
    end

    # сумма для списывания с карточки
    def price_with_payment_commission
      if price_fare && price_tax
        price_total + price_payment
      else
        declared_price || 0
      end
    end

    # комиссия платежного шлюза
    def price_payment
      Payment.commission.reverse_call(price_total)
    end

    # "налоги и сборы" для отображения клиенту
    def price_tax_and_markup
      price_tax + price_markup
    end

    # "налоги и сборы c комиссией" для отображения клиенту
    def price_tax_and_markup_and_payment
      price_tax + price_markup + price_payment - price_declared_discount
    end

    def fee_scheme
      Conf.site.fee_scheme
    end

    # "сбор" для отображения клиенту
    def fee
       #price_markup + price_payment - price_declared_discount
      if fee_scheme == 'v2'
        price_blanks + price_consolidator + price_our_markup + price_payment
      elsif fee_scheme == 'v3'
        price_blanks + price_consolidator + price_our_markup + price_payment+ price_declared_discount
      else
        price_markup + price_payment - price_declared_discount
      end
    end

    def fee_but_no_payment
       price_markup - price_declared_discount
    end

    # "налоги и сборы c комиссией" для отображения клиенту (без эквайринга)
    def price_tax_and_markup_but_no_payment
      price_tax + price_markup - price_declared_discount
    end

    def price_agent
      return 0 unless commission
      commission_agent.call(price_fare, :multiplier =>  blank_count)
    end

    def price_subagent
      return 0 unless commission
      commission_subagent.call(price_fare, :multiplier =>  blank_count)
    end

    def price_consolidator
      return 0 unless commission
      commission_consolidator.call(price_fare, :multiplier => blank_count)
    end

    def price_blanks
      return 0 unless commission
      commission_blanks.call(price_fare, :multiplier => blank_count)
    end

    def price_discount
      return 0 unless commission
      -commission_discount.call(price_fare, :multiplier => blank_count)
    end

    def price_our_markup
      return 0 unless commission
      commission_our_markup.call(price_fare, :multiplier => blank_count)
    end

    def price_declared_discount
      price_discount
    end

    # надбавка к цене амадеуса
    def price_markup
      price_consolidator + price_blanks + price_our_markup + price_discount
    end

    def commission
      @commission ||= Commission.find_for(self)
    end

    # пытаемся избежать сохранения формул в order_forms_cache
    def reset_commission!
      @commission = nil
    end

  end
end
