# encoding: utf-8
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
    # price_acquiring_compensation - компенсация эквайринга, сохраняется в базе, по возможности пересчитывается из билетов
    # fee_scheme - схема расчета поля (сервисный сбор/скидка) v2 - не учитывает price_discount, v3 - учитывает
    # fee_calculation_details - динамическое поле, нужно исключительно для налоговой.

    # рассчет прибыли
    #####################################

    # FIXME аггрегировать в заказе price_penalty по возвратам тоже?
    include IncomeSuppliers
    include FeeCalculationDetails

    def income
      income_earnings - income_suppliers
    end

    # реальный баланс по выписке и платежам
    # FIXME заменить этим income
    def balance
      income_earnings - aggregated_income_suppliers
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
      recalculated_price_with_payment_commission - price_fare - price_declared_discount
    end

    # подгнанный "сбор" для отображения клиенту
    def fee
      if sold_tickets.present? && sold_tickets.all?{|ticket| ticket.price_tax >= 0 && ticket.office_id != 'FLL1S212V' } #мы ебанулись! иначе глючит с трансаэровскими отрицательными таксами
        sold_tickets.to_a.sum(&:fee)
      elsif fee_scheme == 'v2'
        price_blanks + price_consolidator + price_our_markup + price_acquiring_compensation + price_operational_fee + price_difference
      elsif fee_scheme == 'v3'
        price_blanks + price_consolidator + price_discount + price_our_markup + price_acquiring_compensation + price_operational_fee + price_difference
      else
        recalculated_price_with_payment_commission - price_tax - price_fare - price_declared_discount
      end
    end

    def price_declared_discount
      price_discount
    end

    def price_tax_and_markup
      price_tax + price_markup
    end

    def price_real# сумма всех компонентов цены кроме корректировки
      price_total + price_acquiring_compensation
    end

    def price_total
      price_fare + price_tax + price_markup
    end

    def price_markup
      price_consolidator + price_blanks + price_our_markup + price_discount + price_operational_fee
    end

    # FIXME сломается, если там не проценты!
    def acquiring_percentage
      acquiring_commission.rate / 100
    end

    # FIXME отдать это на совесть подклассов Payment
    def acquiring_commission
      return Commission::Formula.new(Conf.cash.corporate_commission) if pricing_method =~ /corporate/
      #так сложно, чтобы не тормознуть генерацию csv
      return payments.to_a.select(&:is_charge?).sort_by(&:created_at).last.commission if payments.to_a.present?
      Commission::Formula.new(Conf.payment.commission)
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
      if has_data_in_tickets?
        sold_tickets.every.vat.sum
      end
    end

    # реальная _ожидаемая_ комиссия на эквайринг (от объявленной суммы)
    def price_payment_commission
      (price_with_payment_commission * acquiring_percentage).round(2)
    end

    # Касса: Режим 1 или 3  (скорректированная доля поставщика, для пробивания НДС в кассе)
    def price_original
      price_tax + price_fare + price_discount
    end

    # Касса: Режим 2 (не облагается НДС)
    def price_tax_extra
      price_with_payment_commission - price_original
    end

    def recalculation
      # price_tax получаются из pnr
      # price_fare получаются из pnr
      # price_difference - неактуально и неверно? грохнуть?
      self.price_agent = commission_agent.apply(price_fare, :multiplier =>  blank_count)
      self.price_subagent = commission_subagent.apply(price_fare, :multiplier =>  blank_count)
      self.price_consolidator = commission_consolidator.apply(price_fare, :multiplier => blank_count)
      self.price_blanks = commission_blanks.apply(price_fare, :multiplier => blank_count)
      # FIXME с появлением отрицательных формул могут быть интересные результаты
      self.price_discount = -commission_discount.apply(price_fare, :multiplier => blank_count)
      self.price_our_markup = commission_our_markup.apply(price_fare, :multiplier => blank_count)
    end
  end
end
