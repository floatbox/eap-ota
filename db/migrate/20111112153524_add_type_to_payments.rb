class AddTypeToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :type, :string
    execute "update payments set type='PaytureCharge'"
    execute "update payments set type='CashCharge' where system = 'cash'"
  end

  def down
    remove_column :payments, :type
  end
end
