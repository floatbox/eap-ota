# Женя: для всех правил DTT скидка=100% комиссии+3%
# осталось с 1 декабря: для всех правил АЦ скидка=100% комиссии+3%
Discount.register "2013-12-02" do
  Discount::Rule.netto(commission, '3%')
end
