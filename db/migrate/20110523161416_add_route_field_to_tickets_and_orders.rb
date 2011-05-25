class AddRouteFieldToTicketsAndOrders < ActiveRecord::Migration
  def self.up
    add_column :tickets, :route, :string
    add_column :orders, :route, :string
    execute('update orders set route = description where source != "other"')
  end

  def self.down
    remove_column :tickets, :route
    remove_column :orders, :route
  end
end

