class AddChargedAtToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :charged_at, :datetime
    remove_column :payments, :charge_date
  end

  def self.down
    remove_column :payments, :charged_at
    add_column :payments, :charge_date, :date
  end
end

