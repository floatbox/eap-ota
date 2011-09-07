class AddSourceToTickets < ActiveRecord::Migration
  def up
    add_column :tickets, :pnr_number, :string, :first => true
    add_column :tickets, :source, :string, :first => true
    # хоть и дата миграция, но
    # в данном случае, относительно безопасно
    execute "update tickets, orders set tickets.pnr_number = orders.pnr_number, tickets.source = orders.source where tickets.order_id = orders.id"
  end

  def down
    remove_column :tickets, :pnr_number
    remove_column :tickets, :source
  end
end
