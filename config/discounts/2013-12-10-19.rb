# для некомиссионные  АЦ правил скидка =0
# для остальных АЦ правил скидка = 50% комиссии
# для ДТТ правил скидка=100% комиссии+4%
# для app-ios 1000 маркап
# для прямого 500 маркап
Discount.register "2013-12-10 19" do
  case context.partner_code
  when 'anonymous'
    Discount::Rule.new(our_markup: 500)
  when 'app-ios'
    Discount::Rule.new(our_markup: 1000)
  else
    case commission.ticketing_method
    when 'downtown'
      Discount::Rule.netto(commission, '4%')
    else
      Discount::Rule.scaled(commission, 0.5)
    end
  end
end
