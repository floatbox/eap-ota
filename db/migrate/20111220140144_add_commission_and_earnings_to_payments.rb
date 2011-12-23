class AddCommissionAndEarningsToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :commission, :string
    add_column :payments, :earnings, :decimal, :precision => 9, :scale => 2, :default => 0.0, :null => false
    # выставляем параметры, как будто всегда указывали комиссию
    execute "update payments set commission = '2.85%'"
    execute "update payments set commission = '3.25%' where created_at < '2011-09-06'"
    execute "update payments set commission = '2.8%' where created_at > '2012-01-23'"
    execute "update payments, orders set payments.commission = '0' where payments.type = 'CashCharge' and orders.pricing_method ='corporate_0001' and orders.id = payments.order_id"

    execute "update payments set earnings = price*(1-0.0285) where commission = '2.85%'"
    execute "update payments set earnings = price*(1-0.028) where commission = '2.8%'"
    execute "update payments set earnings = price*(1-0.0325) where commission = '3.25%'"
    execute "update payments set earnings = price where commission = '0'"
  end

  def down
    remove_column :payments, :earnings
    remove_column :payments, :commission
  end
end
