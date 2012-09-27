class CreateStoredFlightsTickets < ActiveRecord::Migration
  def change
    create_table :stored_flights_tickets, :id => false do |t|
      t.references :stored_flight
      t.references :ticket
    end
    add_index :stored_flights_tickets, [:stored_flight_id, :ticket_id]
  end
end
