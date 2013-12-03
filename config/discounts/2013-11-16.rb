# Коля:
# для ДТТ - скидки вообще убираем
# для АЦ комиссионных - тоже убираем
# для некомиссионных - надбавка 100 р. с билета.
Discount.register '2013-11-16' do
  if no_commission?(commission)
    Discount::Rule.new(our_markup: '100')
  end
end
