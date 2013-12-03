# Женя:
# для правил ДТТ увеличиваем скидку = 100% комиссии+3,5%
# для комиссионных правил АЦ скидка=30%

Discount.register '2013-11-18' do
  case commission.ticketing_method
  when 'downtown'
    Discount::Rule.netto(commission, '3.5%')
  when 'aviacenter', 'direct'
    Discount::Rule.scaled(commission, 0.3)
  end
end
