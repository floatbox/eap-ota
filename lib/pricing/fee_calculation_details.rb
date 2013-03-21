# encoding: utf-8
module Pricing
  module FeeCalculationDetails
    def fee_calculation_details
      result = <<eos
        1. Дата и время вормирования заказа: #{created_at.strftime('%d.%m.%y %H:%M')}<br/>
        2. #{commission_carrier}:Агент #{commission_agent_comments}<br/>
            Субагент #{commission_subagent_comments}<br/>
        3. тариф: #{price_fare.round(2)}<br/>
           таксы: #{price_tax.round(2)}<br/>
           сбор за бланки: #{price_blanks.round(2)}<br/>
           сбор 1/2% АЦ/Даунтаун: #{price_consolidator.round(2)}<br/>
           компенсация от тарифа: #{price_discount.round(2)}<br/>
           надбавка к тарифу: #{(price_our_markup + price_difference).round(2)}<br/>
           компенсация эквайринга: #{price_acquiring_compensation.round(2)}<br/>
           сбор за операцию: #{price_operational_fee.round(2)}<br/>
eos
      if fee_scheme == 'v2'
        result += "4. [ИТОГО: сервисный сбор/скидка #{fee.round(2)}] = [сбор за бланки #{price_blanks.round(2)}] + [сбор 1/2% АЦ/ДаунТаун #{price_consolidator.round(2)}] + [надбавка к тарифу #{(price_our_markup + price_difference).round(2)}] + [компенсация эквайринга #{price_acquiring_compensation.round(2)}] + [сбор за операцию #{price_operational_fee.round(2)}]"
      elsif fee_scheme == 'v1'
        result += "4. [ИТОГО: сервисный сбор/скидка #{fee.round(2)}] = [сбор за бланки #{price_blanks.round(2)}] + [сбор 1/2% АЦ/ДаунТаун #{price_consolidator.round(2)}] + [компенсация от тарифа #{price_discount.round(2)}]+ [надбавка к тарифу #{(price_our_markup + price_difference).round(2)}] + [компенсация эквайринга #{price_acquiring_compensation.round(2)}] + [сбор за операцию #{price_operational_fee.round(2)}]"
      end
      result
    end

  end
end
