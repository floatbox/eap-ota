class AddCardNameAndCardLastDigitsToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :name_in_card, :string
    add_column :orders, :last_digits_in_card, :string
  end

  def self.down
    drop_column :orders, :name_in_card
    drop_column :orders, :last_digits_in_card
  end
end
