class AddCommissionsToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :commission_agent, :string
    add_column :tickets, :commission_consolidator_markup, :string
  end
end
