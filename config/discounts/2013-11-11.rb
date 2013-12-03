#when Time.new(2013, 11, 11,  19, 30).past?

# Коля: надо сделать 3.5%
Discount::Book.default_book.register('2013-11-11', Proc.new do
  Discount::Rule.netto(commission, '3.5%')
end)
