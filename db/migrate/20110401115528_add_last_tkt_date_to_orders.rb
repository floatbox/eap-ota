class AddLastTktDateToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :last_tkt_date, :date
  end

  def self.down
    remove_column :orders, :last_tkt_date
  end
end

