class ChangeDefaultOrderSourceToOther < ActiveRecord::Migration
  def self.up
    change_column :orders, :source, :string, :default => 'other'
    change_column :orders, :payment_status, :string, :default => 'new'
  end

  def self.down
  end
end

