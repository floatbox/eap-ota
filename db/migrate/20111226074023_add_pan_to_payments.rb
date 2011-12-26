class AddPanToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :pan, :string
    execute "update payments set pan = concat('xxxxxxxxxxxx', last_digits_in_card)"
  end

  def down
    remove_column :payments, :pan
  end
end
