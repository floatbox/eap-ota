class AddSomeFieldsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :price_with_payment_commission, :integer
    add_column :orders, :order_id, :string
    add_column :orders, :full_info, :string
    add_column :orders, :payment_status, :string
  end

  def self.down
    remove_column :orders, :price_with_payment_commission
    remove_column :orders, :order_id
    remove_column :orders, :full_info
    remove_column :orders, :payment_status
  end
end
