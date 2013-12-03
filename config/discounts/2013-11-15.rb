# Женя: для правил ДТТ скидка=70% комиссии
Discount.register '2013-11-15' do
  case commission.ticketing_method
  when 'downtown'
    Discount::Rule.scaled(commission, 0.7)
  end
end
