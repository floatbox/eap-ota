class AddMsoNumberToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :mso_number, :string
  end
end
