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

    # рассчет прибыли
    #####################################

    # FIXME аггрегировать в заказе price_penalty по возвратам тоже?
    include IncomeSuppliers

    def income
      @income ||= income_earnings - income_suppliers
    end

    # реальный баланс по выписке и платежам
    # FIXME заменить этим income
    def balance
      @balance ||= income_earnings - aggregated_income_suppliers
    end

    def expected_income
      (expected_earnings - income_suppliers).round(2).to_d
    end

    # сумма данных по билетам. по идее, более точная информация, нежели сохраненная в заказе
    # FIXME заменить этим income_suppliers
    def aggregated_income_suppliers
       tickets.sold.to_a.sum(&:income_suppliers)
    end

    def income_payment_gateways
      secured_payments.to_a.sum(&:income_payment_gateways)
    end

    def income_earnings
      secured_payments.to_a.sum(&:earnings)
    end

    # подгнанные "налоги и сборы c комиссией" для отображения клиенту
    def price_tax_and_markup_and_payment
      recalculated_price_with_payment_commission - price_fare + price_declared_discount
    end

    # подгнанный "сбор" для отображения клиенту
    def fee
      if sold_tickets.present? && sold_tickets.all?{|ticket| ticket.price_tax >= 0 && ticket.office_id != 'FLL1S212V' } #мы ебанулись! иначе глючит с трансаэровскими отрицательными таксами
        sold_tickets.to_a.sum(&:fee)
      else
        recalculated_price_with_payment_commission - price_tax - price_fare + price_declared_discount
      end
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

    # FIXME сломается, если там не проценты!
    def acquiring_percentage
      acquiring_commission.rate / 100
    end

    # FIXME отдать это на совесть подклассов Payment
    def acquiring_commission
      commission =
        if pricing_method =~ /corporate/
          Conf.cash.corporate_commission
        elsif payment_type == 'cash'
          Conf.cash.commission
        else
          Conf.payture.commission
        end
      Commission::Formula.new(commission)
    end

    # FIXME отдать это на совесть подклассов Payment
    def expected_earnings
      if payment_type == 'card'
        price_with_payment_commission - price_payment_commission #price_total
      else # cash, delivery, invoice..
        price_with_payment_commission
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

    # Касса: Режим 1 или 3  (скорректированная доля поставщика, для пробивания НДС в кассе)
    def price_original
      price_tax + price_fare - price_discount
    end

    # Касса: Режим 2 (не облагается НДС)
    def price_tax_extra
      price_with_payment_commission - price_original
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
