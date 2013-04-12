class CreateImportsTickets < ActiveRecord::Migration
  def change
    create_table :imports_tickets, :id => false do |t|
      t.references :import
      t.references :ticket
    end
    add_index :imports_tickets, [:import_id, :ticket_id]
  end
end
