# Женя: для правил ДТТ скидка=70% комиссии
Discount::Book.default_book.register('2013-11-15', Proc.new do
  case commission.ticketing_method
  when 'downtown'
    Discount::Rule.scaled(commission, 0.7)
  end
end)
