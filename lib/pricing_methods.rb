module PricingMethods
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
    # price_share,
    # price_our_markup,
    # price_consolidator_markup

    # считаются в "что-то для пересчета комиссии"
    # price_with_payment_commission

    # price_difference - что?
    # еще требует blank_count

    # cash_payment_markup содержит доставку, и нигде потом не используется

    def price_tax_and_markup_and_payment
      price_with_payment_commission - price_fare
    end

    def price_tax_and_markup
      price_tax + price_consolidator_markup + price_our_markup
    end

    def price_total
      price_fare + price_tax + price_our_markup + price_consolidator_markup
    end

    def recalculation
      # price_tax получаются из pnr
      # price_fare получаются из pnr
      # price_difference - неактуально и неверно? грохнуть?
      self.price_share = commission_subagent.call(price_fare, :multiplier =>  blank_count)
      self.price_consolidator_markup = commission_consolidator_markup.call(price_fare, :multiplier => blank_count)

      # cash_payment_markup оставлять ее тоже?
      # price_our_markup внести сюда скидку для кэша?

      self.price_with_payment_commission = price_total + Payture.commission(price_total)
    end
  end

  module Ticket
    ### formulas:
    # commission_subagent
    #
    ### prices:
    # price_fare
    # price_tax
    # price_share
    # price_consolidator_markup

  end
end
