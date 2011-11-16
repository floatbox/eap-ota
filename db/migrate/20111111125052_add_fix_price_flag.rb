class AddFixPriceFlag < ActiveRecord::Migration
  def up
    add_column :orders, :fix_price, :boolean, :null => false, :default => false
    execute "update orders set fix_price = 1 where payment_status in ('charged', 'blocked')"
  end

  def down
    remove_column :orders, :fix_price
  end
end
