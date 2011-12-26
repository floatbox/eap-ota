class AddPanToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :pan, :string
    execute "update orders set pan = concat('xxxxxxxxxxxx', last_digits_in_card)"
  end

  def down
    remove_column :orders, :pan
  end
end
