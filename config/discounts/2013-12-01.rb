# Женя: для всех правил АЦ скидка=100% комиссии+3%
# осталось с 28 ноября: DTT скидки=50% комиссии
Discount.register "2013-12-01" do
  if commission.ticketing_method == 'downtown'
    Discount::Rule.scale(commission, 0.5)
  else
    Discount::Rule.netto(commission, '3%')
  end
end
