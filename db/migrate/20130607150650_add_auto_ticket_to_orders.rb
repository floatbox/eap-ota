class AddAutoTicketToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :auto_ticket, :boolean, default: false
  end
end
