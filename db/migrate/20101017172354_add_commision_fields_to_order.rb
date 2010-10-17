class AddCommisionFieldsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :price_total, :integer
    add_column :orders, :price_base, :integer
    add_column :orders, :commission_carrier, :string
    add_column :orders, :commission_agent, :string
    add_column :orders, :commission_subagent, :string
    add_column :orders, :markup, :integer
  end

  def self.down
    remove_column :orders, :price_total
    remove_column :orders, :price_base
    remove_column :orders, :commission_carrier
    remove_column :orders, :commission_agent
    remove_column :orders, :commission_subagent
    remove_column :orders, :markup
  end
end
