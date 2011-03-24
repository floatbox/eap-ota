class AddMoreFieldsToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :reject_reason, :string
    add_column :payments, :id_override, :string
  end

  def self.down
    remove_column :payments, :reject_reason
    remove_column :payments, :id_override
  end
end

