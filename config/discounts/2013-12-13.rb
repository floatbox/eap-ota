# для app-ios 500 маркап
# для прямого половину от комиссии на комиссионные и маркап 250 р. на некомиссионные
# для остальных скидки 5% от нетто
Discount.register "2013-12-12" do
  case context.partner_code
  when 'anonymous'
    if commission.subagent.extract('%') > Fx(0)
      Discount::Rule.scaled(commission, 0.5)
    else
      Discount::Rule.new(our_markup: 250)
    end
  when 'app-ios'
    Discount::Rule.new(our_markup: 500)
  else
    Discount::Rule.netto(commission, '5%')
  end
end
