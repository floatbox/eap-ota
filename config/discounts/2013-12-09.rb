# для некомиссионные  АЦ правил скидка =0
# для остальных АЦ правил скидка = 50% комиссии
# для ДТТ правил скидка=100% комиссии+3,5%
Discount.register "2013-12-09" do
  case commission.ticketing_method
  when 'downtown'
    Discount::Rule.netto(commission, '3.5%')
  else
    Discount::Rule.scale(commission, 0.5)
  end
end
