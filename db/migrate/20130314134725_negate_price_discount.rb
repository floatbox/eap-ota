class NegatePriceDiscount < ActiveRecord::Migration
  def up
    execute 'UPDATE orders SET price_discount = -price_discount'
    execute 'UPDATE tickets SET price_discount = -price_discount'
  end

  def down
    execute 'UPDATE orders SET price_discount = -price_discount'
    execute 'UPDATE tickets SET price_discount = -price_discount'
  end
end
