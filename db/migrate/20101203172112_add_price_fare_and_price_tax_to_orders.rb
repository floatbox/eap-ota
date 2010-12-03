class AddPriceFareAndPriceTaxToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :price_fare, :integer
    add_column :orders, :price_tax, :integer
    remove_column :orders, :first_name
    remove_column :orders, :surname
  end

  def self.down
    remove_column :orders, :price_fare
    remove_column :orders, :price_tax
    add_column :orders, :first_name, :string
    add_column :orders, :surname, :string
  end
end
