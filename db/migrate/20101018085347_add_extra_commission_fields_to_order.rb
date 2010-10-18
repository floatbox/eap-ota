class AddExtraCommissionFieldsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :extra, :integer
  end

  def self.down
    remove_column :orders, :extra
  end
end
