class AddBaggageInfoToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :baggage_info, :string
  end
end
