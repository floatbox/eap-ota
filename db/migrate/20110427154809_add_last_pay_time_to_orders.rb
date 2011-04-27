class AddLastPayTimeToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :last_pay_time, :datetime
  end

  def self.down
    remove_column :orders, :last_pay_time
  end
end

