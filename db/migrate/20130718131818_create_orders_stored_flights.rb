class CreateOrdersStoredFlights < ActiveRecord::Migration
  def change
    create_table :orders_stored_flights, :id => false do |t|
      t.references :stored_flight
      t.references :order
    end
    add_index :orders_stored_flights, [:stored_flight_id, :order_id]
    add_index :orders_stored_flights, [:order_id, :stored_flight_id]
  end
end
