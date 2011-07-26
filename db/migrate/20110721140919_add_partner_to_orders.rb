class AddPartnerToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :partner, :string
  end

  def self.down
    remove_column :orders, :partner
  end
end
