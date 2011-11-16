class AddTicketingMethodToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :commission_ticketing_method, :string, :default => '', :null => false
  end
end
