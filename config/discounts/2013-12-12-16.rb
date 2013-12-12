# для АЦ правил скидка =100% комиссии+4.5%
# для ДТТ правил скидка=100% комиссии+4.5%
# для app-ios 1000 маркап
# для прямого 500 маркап
Discount.register "2013-12-12 16:00" do
  case context.partner_code
  when 'anonymous'
    Discount::Rule.new(our_markup: 500)
  when 'app-ios'
    Discount::Rule.new(our_markup: 1000)
  else
    Discount::Rule.netto(commission, '4.5%')
  end
end
