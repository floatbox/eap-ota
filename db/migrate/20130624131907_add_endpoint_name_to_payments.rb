class AddEndpointNameToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :endpoint_name, :string, :default => ''
  end
end
