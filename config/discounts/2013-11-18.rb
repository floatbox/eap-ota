Discount::Book.default_book.register('2013-11-18', Proc.new do
  case commission.ticketing_method
  when 'downtown'
    Discount::Rule.netto(commission, '3.5%')
  when 'aviacenter', 'direct'
    Discount::Rule.scaled(commission, 0.3)
  end
end)
