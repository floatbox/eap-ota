module Pricing
  module Recommendation

    attr_accessor :price_fare, :price_tax, :blank_count

    delegate :subagent, :agent, :consolidator, :blanks, :discount, :our_markup, :ticketing_method,
      :to => :commission, :prefix => :commission, :allow_nil => true

    # вкручиваем шурупами income и в рекомендации
    # FIXME убрать лишние методы
    include IncomeDistribution

    # для совместимости с рассчетом income_suppliers
    def price_penalty; 0 end
    def supplier_billed?; true end

    # FIXME работает для текущей схемы, считает что мы эквайринг не берем себе в общем случае
    def income
      @income ||= price_total - income_suppliers
    end

    # составные части стоимости

    # сумма, которая придет нам от платежного шлюза
    def price_total
      price_fare + price_tax + price_markup
    end

    # сумма для списывания с карточки
    def price_with_payment_commission
      price_total + price_payment
    end

    # комиссия платежного шлюза
    def price_payment
      Payture.commission.reverse_call(price_total)
    end

    # "налоги и сборы" для отображения клиенту
    def price_tax_and_markup
      price_tax + price_markup
    end

    # "налоги и сборы c комиссией" для отображения клиенту
    def price_tax_and_markup_and_payment
      price_tax + price_markup + price_payment + price_declared_discount
    end

    # "налоги и сборы c комиссией" для отображения клиенту (без эквайринга)
    def price_tax_and_markup_but_no_payment
      price_tax + price_markup + price_declared_discount
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
      commission_discount.call(price_fare, :multiplier => blank_count)
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
      price_consolidator + price_blanks + price_our_markup - price_discount
    end

    def commission
      @commission ||=
        if source == 'sirena'
          Sirena::Commission.find_for(self)
        else
          Commission.find_for(self)
        end
    end

    # пытаемся избежать сохранения формул в order_forms_cache
    def reset_commission!
      @commission = nil
    end

  end
end
