module PricingMethods
  # V----- также есть в билетах
  #   V-- не сохранены в заказах (рассчитываются)
  #      наше название колонки:            хочется:
  # *    price_fare                        1. Тариф Fare (цифры)
  # *    price_tax                         2. Таксы Taxes (цифры)
  #      commission_consolidator_markup    3. Сбор авиацентра % Aviacenter fee % (0/1%/2%)
  #      price_consolidator_markup         4. Сбор авиацентра в рублях Aviacenter fee RUB [=п.1 Fare * п.3 Aviacenter fee]
  #      ??? price_blanks                  5. Сбор за бланки RUB (цифры)
  #      ??? (commission_blanks)
  #      price_our_markup                  6. Сервисный сбор Эвитерра Eviterra fee (цифры)
  #      ??? (commission_our_markup)       - до эквайринга? может еще один, после эквайринга, сделать?
  #
  #
  #   *  price_total                       7. Итого себестоимость билета Ticket price total [=1+2+4+5+6]
  #   *  ??? price_payment_commission      8. Комиссия за эквайринг Bank fee [=(п.7*3,25%)/(100%-3,25%)] 
  #      price_with_payment_commission     9. Итого к оплате TOTAL CLIENT PRICE [=п.7+п.8]
  #
  #   *  price_original                    Поле "Режим 1 или 3" (цифра) [=п.1+п.2]
  #
  #   *  price_tax_extra                   Поле "Режим 2" (цифра) [=п.4+5+6+8]
  #          но есть:
  #          price_tax_and_markup_and_payment = price_tax_extra + price_tax
  #          price_tax_and_markup             = price_tax_extra - price_payment_commission
  #
  #      не учтены, но есть:
  #      price_share                       наша доля комиссии (субагентская)
  #        (commission_subagent)
  #      price_difference                  price_total - price_total_old, рассчитывается после первой загрузки билетов

  #      price_transfer                   - есть у билетов, вычисляется. используется?
  #
  #      ??? price_income                     прибыль?
  #      методы: карта
  #              кэш
  #              безналичка
  #
  #   что отображаем клиенту? как это влияет на предыдущие цифры если расходится с себестоимостью?

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

    # price_difference = price_total - price_total_old, рассчитывается после первой загрузки билетов
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

    def calculate_price_with_payment_commission
      if pricing_method =~ /corporate/
        self.price_with_payment_commission = price_total
      else
        self.price_with_payment_commission = price_total + Payture.commission(price_total)
      end
    end

    def price_payment_commission
      Payture.commission(price_total)
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
      self.price_share = commission_subagent.call(price_fare, :multiplier =>  blank_count)
      self.price_consolidator_markup = commission_consolidator_markup.call(price_fare, :multiplier => blank_count)

      # cash_payment_markup оставлять ее тоже?
      # price_our_markup внести сюда скидку для кэша?

      self.price_with_payment_commission = price_total + Payture.commission(price_total)
    end
  end

  module Ticket
    ### formulas:
    # уже есть в базе: commission_subagent
    #
    # делегируются в заказ:
    # commission_agent
    # commission_subagent
    # commission_consolidator_markup
    #
    ### prices:
    # price_fare
    # price_tax
    # price_share
    # price_consolidator_markup

    def price_total
      price_fare + price_tax
    end

    def price_transfer
      price_fare + price_tax + price_consolidator_markup - price_share
    end

    def price_refund
      if kind == 'refund'
        -(price_tax + price_fare + price_penalty)
      else
        0
      end
    end

    #FIXME это костыль, работает не всегда, нужно сделать нормально
    def price_with_payment_commission
      k = (price_tax + price_fare).to_f / (order.price_fare + order.price_tax)
      order.price_with_payment_commission * k
    end

    def price_tax_and_markup_and_payment
      price_with_payment_commission - price_fare
    end

    def recalculate_commissions
      if commission_subagent
        self.price_share = commission_subagent.call(price_fare)
      end
      if commission_consolidator_markup
        self.price_consolidator_markup = commission_consolidator_markup.call(price_fare)
      end
      true
    end

  end
end
