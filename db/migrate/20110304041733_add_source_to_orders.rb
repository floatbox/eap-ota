class AddSourceToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :source, :string
    execute "update orders set source = 'amadeus'"
  end

  def self.down
    remove_column :orders, :source, :string
  end
end
