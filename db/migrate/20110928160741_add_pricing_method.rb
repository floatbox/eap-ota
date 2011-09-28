class AddPricingMethod < ActiveRecord::Migration
  def change
    add_column :orders, :pricing_method, :string, :null => false, :default => ''
  end
end
