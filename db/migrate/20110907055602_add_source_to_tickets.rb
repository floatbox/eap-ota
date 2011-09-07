class AddSourceToTickets < ActiveRecord::Migration
  def up
    add_column :tickets, :pnr_number, :string, :first => true
    add_column :tickets, :source, :string, :first => true
  end
end
