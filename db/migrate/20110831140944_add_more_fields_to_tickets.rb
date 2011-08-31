class AddMoreFieldsToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :validator, :string
    add_column :tickets, :status, :string
    add_column :tickets, :office_id, :string
    add_column :tickets, :ticketed_date, :date
    add_column :tickets, :validating_carrier, :string
  end
end
