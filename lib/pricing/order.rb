module Pricing
  module Order

    # это лежит в базе, скопировано из recommendation.commission
    #  в том числе формулы:
    # commission_agent
    # commission_subagent
    # commission_consolidator_markup
    #  а также
    # commission_carrier
    # commission_agent_comments
    # commission_subagent_comments
    #
    #  из рекомендации, но пересчитываются и тут тоже:
    # price_fare
    # price_tax
    # price_subagent,
    # price_consolidator
    # price_blanks

    # считаются в "что-то для пересчета комиссии"
    # price_with_payment_commission

    # price_difference = price_total - price_total_old, рассчитывается после первой загрузки билетов
    # еще требует blank_count

    # cash_payment_markup содержит доставку, и нигде потом не используется

    # подгнанные "налоги и сборы c комиссией" для отображения клиенту
    def price_tax_and_markup_and_payment
      recalculated_price_with_payment_commission - price_fare + price_declared_discount
    end

    def price_declared_discount
      price_discount
    end

    def price_tax_and_markup
      price_tax + price_markup
    end

    def price_total
      price_fare + price_tax + price_markup
    end

    def price_markup
      price_consolidator + price_blanks + price_our_markup - price_discount
    end

    def acquiring_percentage
      if pricing_method =~ /corporate/
        0
      else
        Payture.pcnt
      end
    end

    def calculate_price_with_payment_commission
      self.price_with_payment_commission = price_total + acquiring_compensation(price_total, acquiring_percentage)
    end

    def acquiring_compensation(price, percentage)
      (percentage * price / ( 1 - percentage)).round(2)
    end
    private :acquiring_compensation

    def vat
      if sold_tickets.present?
        sold_tickets.every.vat.sum
      end
    end

    # реальная _ожидаемая_ комиссия на эквайринг (от объявленной суммы)
    def price_payment_commission
      price_with_payment_commission * acquiring_percentage
    end

    def price_original
      price_tax + price_fare
    end

    def price_tax_extra
      price_tax_and_markup + price_payment_commission
    end

    def recalculation
      # price_tax получаются из pnr
      # price_fare получаются из pnr
      # price_difference - неактуально и неверно? грохнуть?
      self.price_agent = commission_agent.call(price_fare, :multiplier =>  blank_count)
      self.price_subagent = commission_subagent.call(price_fare, :multiplier =>  blank_count)
      self.price_consolidator = commission_consolidator.call(price_fare, :multiplier => blank_count)
      self.price_blanks = commission_blanks.call(price_fare, :multiplier => blank_count)
      self.price_discount = commission_discount.call(price_fare, :multiplier => blank_count)
      self.price_our_markup = commission_our_markup.call(price_fare, :multiplier => blank_count)
    end
  end
end
