# добавляет команду ">", которая сохраняет предыдущий результат в переменную.
# пример:
# pry> Order.all
# ...
# pry> >orders
Pry::Commands.block_command /^>(.*)/, 'Assign last result to a variable', :listing => 'assign-result' do |var|
 target.eval "#{var} = _;"
end

# реагировать на изменение размеров терминала
Pry.auto_resize!
