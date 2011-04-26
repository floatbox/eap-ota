class AddThreedsKeyToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :threeds_key, :string
  end

  def self.down
    remove_column :payments, :threeds_key
  end
end

