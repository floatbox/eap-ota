class AddLeadPassToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :sirena_lead_pass, :string
  end

  def self.down
    remove_column :orders, :sirena_lead_pass
  end
end
