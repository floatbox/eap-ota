Discount::Book.default_book.register("2013-11-22", Proc.new do
  rule = Discount::Rule.netto(commission, '4%')
  if rule.discount > Fx('12%')
    rule = Discount::Rule.new(discount: Fx('12%'))
  end
  rule
end)
