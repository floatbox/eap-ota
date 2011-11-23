module Pricing
  # V----- также есть в билетах
  #   V-- не сохранены в заказах (рассчитываются)
  #      наше название колонки:            хочется:
  # *    price_fare                        1. Тариф Fare (цифры)
  # *    price_tax                         2. Таксы Taxes (цифры)
  #      commission_consolidator           3. Сбор авиацентра % Aviacenter fee % (0/1%/2%)
  #      price_consolidator                4. Сбор авиацентра в рублях Aviacenter fee RUB [=п.1 Fare * п.3 Aviacenter fee]
  #      ??? price_blanks                  5. Сбор за бланки RUB (цифры)
  #      ??? commission_blanks
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
  #      price_subagent                       наша доля комиссии (субагентская)
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
  #


end
