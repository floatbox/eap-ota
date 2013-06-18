class AddNoAutoTicketReasonToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :no_auto_ticket_reason, :string, default: ''
  end
end
