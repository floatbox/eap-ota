# для app-ios 500 маркап
# для прямого половину от комиссии на комиссионные и маркап 250 р. на некомиссионные
# для АЦ скидка 6% от нетто
# для DTT скидка 5.5% от нетто
Discount.register "2013-12-16 12:42" do
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
    case commission.ticketing_method
    when 'aviacenter'
      Discount::Rule.netto(commission, '6%')
    else
      Discount::Rule.netto(commission, '5.5%')
    end
  end
end

# для app-ios 500 маркап
# для прямого половину от комиссии на комиссионные и маркап 250 р. на некомиссионные
# для остальных скидки 5.5% от нетто
Discount.register "2013-12-13 16:00" do
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
    Discount::Rule.netto(commission, '5.5%')
  end
end

# для app-ios 500 маркап
# для прямого половину от комиссии на комиссионные и маркап 250 р. на некомиссионные
# для остальных скидки 5% от нетто
Discount.register "2013-12-13" do
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

# для АЦ правил скидка =100% комиссии+5%
# для ДТТ правил скидка=100% комиссии+5%
# для app-ios 1000 маркап
# для прямого 500 маркап
Discount.register "2013-12-12 19:00" do
  case context.partner_code
  when 'anonymous'
    Discount::Rule.new(our_markup: 500)
  when 'app-ios'
    Discount::Rule.new(our_markup: 1000)
  else
    Discount::Rule.netto(commission, '5%')
  end
end

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

# для АЦ правил скидка =100% комиссии+4%
# для ДТТ правил скидка=100% комиссии+4%
# для app-ios 1000 маркап
# для прямого 500 маркап
Discount.register "2013-12-11" do
  case context.partner_code
  when 'anonymous'
    Discount::Rule.new(our_markup: 500)
  when 'app-ios'
    Discount::Rule.new(our_markup: 1000)
  else
    Discount::Rule.netto(commission, '4%')
  end
end

# для АЦ правил скидка =100% комиссии+4.5%
# для ДТТ правил скидка=100% комиссии+4.5%
# для app-ios 1000 маркап
# для прямого 500 маркап
Discount.register "2013-12-11 16:00" do
  case context.partner_code
  when 'anonymous'
    Discount::Rule.new(our_markup: 500)
  when 'app-ios'
    Discount::Rule.new(our_markup: 1000)
  else
    Discount::Rule.netto(commission, '4.5%')
  end
end

# для некомиссионные  АЦ правил скидка =0
# для остальных АЦ правил скидка = 50% комиссии
# для ДТТ правил скидка=100% комиссии+4%
# для app-ios 1000 маркап
# для прямого 500 маркап
Discount.register "2013-12-10 19" do
  case context.partner_code
  when 'anonymous'
    Discount::Rule.new(our_markup: 500)
  when 'app-ios'
    Discount::Rule.new(our_markup: 1000)
  else
    case commission.ticketing_method
    when 'downtown'
      Discount::Rule.netto(commission, '4%')
    else
      Discount::Rule.scaled(commission, 0.5)
    end
  end
end

# для некомиссионные  АЦ правил скидка =0
# для остальных АЦ правил скидка = 50% комиссии
# для ДТТ правил скидка=100% комиссии+4%
# для app-ios 1000 маркап
# для прямого 500 маркап
Discount.register "2013-12-10 17" do
  case context.partner_code
  when 'anonymous'
    Discount::Rule.new(our_markup: 500)
  when 'app-ios'
    Discount::Rule.new(our_markup: 1000)
  else
    case commission.ticketing_method
    when 'downtown'
      Discount::Rule.netto(commission, '3.5%')
    else
      Discount::Rule.scaled(commission, 0.5)
    end
  end
end

# для некомиссионные  АЦ правил скидка =0
# для остальных АЦ правил скидка = 50% комиссии
# для ДТТ правил скидка=100% комиссии+3,5%
Discount.register "2013-12-09" do
  case commission.ticketing_method
  when 'downtown'
    Discount::Rule.netto(commission, '3.5%')
  else
    Discount::Rule.scaled(commission, 0.5)
  end
end

# Коля: текущие скидки+1%
Discount.register "2013-12-06 07:10" do
  Discount::Rule.netto(commission, '5.5%')
end

# Женя: текущие скидки+1%
Discount.register "2013-12-03" do
  Discount::Rule.netto(commission, '4%')
end

# Коля: текущие скидки+0.5%
Discount.register "2013-12-03 22:00" do
  Discount::Rule.netto(commission, '4.5%')
end
# Женя: для всех правил DTT скидка=100% комиссии+3%
# осталось с 1 декабря: для всех правил АЦ скидка=100% комиссии+3%
Discount.register "2013-12-02" do
  Discount::Rule.netto(commission, '3%')
end

# Женя: для всех правил АЦ скидка=100% комиссии+3%
# осталось с 28 ноября: DTT скидки=50% комиссии
Discount.register "2013-12-01" do
  if commission.ticketing_method == 'downtown'
    Discount::Rule.scale(commission, 0.5)
  else
    Discount::Rule.netto(commission, '3%')
  end
end
# скидки netto + 4%, но не больше 12%

Discount.register "2013-11-22" do
  rule = Discount::Rule.netto(commission, '4%')
  if rule.discount > Fx('12%')
    rule = Discount::Rule.new(discount: Fx('12%'))
  end
  rule
end
# Женя:
# для правил ДТТ увеличиваем скидку = 100% комиссии+3,5%
# для комиссионных правил АЦ скидка=30%

Discount.register '2013-11-18' do
  case commission.ticketing_method
  when 'downtown'
    Discount::Rule.netto(commission, '3.5%')
  when 'aviacenter', 'direct'
    Discount::Rule.scaled(commission, 0.3)
  end
end

# Коля:
# для ДТТ - скидки вообще убираем
# для АЦ комиссионных - тоже убираем
# для некомиссионных - надбавка 100 р. с билета.
Discount.register '2013-11-16' do
  if no_commission?(commission)
    Discount::Rule.new(our_markup: '100')
  end
end

# Женя: для правил ДТТ скидка=70% комиссии
Discount.register '2013-11-15' do
  case commission.ticketing_method
  when 'downtown'
    Discount::Rule.scaled(commission, 0.7)
  end
end

# Коля: надо сделать 3.5%
Discount.register '2013-11-11 19:30:00' do
  Discount::Rule.netto(commission, '3.5%')
end
