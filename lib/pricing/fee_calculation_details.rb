# encoding: utf-8
module Pricing
  module FeeCalculationDetails
    def fee_calculation_string
      result = <<eos
        1. Дата и время вормирования заказа: #{created_at.strftime('%d.%m.%y %H:%M')}<br/>
        2. #{commission_carrier}:Агент #{commission_agent_comments}<br/>
            Субагент #{commission_subagent_comments}<br/>
        3. тариф: #{price_fare}<br/>
           таксы: #{price_tax}<br/>
           сбор за бланки: #{price_blanks}<br/>
           сбор 1/2% АЦ/Даунтаун: #{price_consolidator}<br/>
           компенсация от тарифа: #{price_discount}<br/>
           надбавка к тарифу: #{(price_our_markup + price_difference).round(2)}<br/>
           компенсация эквайринга: #{price_acquiring_compensation}<br/>
           сбор за операцию: #{price_operational_fee}<br/>
eos
      if fee_scheme == 'v2'
        result += "4. [ИТОГО: сервисный сбор/скидка #{fee}] = [сбор за бланки #{price_blanks}] + [сбор 1/2% АЦ/ДаунТаун #{price_consolidator}] + [надбавка к тарифу #{price_our_markup + price_difference}] + [компенсация эквайринга #{price_acquiring_compensation}] + [сбор за операцию #{price_operational_fee}]"
      elsif fee_scheme == 'v1'
        result += "4. [ИТОГО: сервисный сбор/скидка #{fee}] = [сбор за бланки #{price_blanks}] + [сбор 1/2% АЦ/ДаунТаун #{price_consolidator}] + [компенсация от тарифа #{price_discount}] + [надбавка к тарифу #{price_our_markup + price_difference}] + [компенсация эквайринга #{price_acquiring_compensation}] + [сбор за операцию #{price_operational_fee}]"
      end
      result
    end

  end
end
