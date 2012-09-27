class CreateStoredFlights < ActiveRecord::Migration
  def change
    create_table :stored_flights do |t|
      t.string :departure_iata, :limit => 3
      t.string :arrival_iata, :limit => 3
      t.string :departure_term, :limit => 1
      t.string :arrival_term, :limit => 1
      
      t.string :marketing_carrier_iata, :limit => 2
      t.string :operating_carrier_iata, :limit => 2
      t.string :flight_number, :limit => 5

      t.date :dept_date
      t.string :departure_time, :limit => 4
      t.date :arrv_date
      t.string :arrival_time, :limit => 4
      
      t.string :equipment_type_iata, :limit => 4
      t.integer :technical_stop_count
      t.integer :duration
      
      t.timestamps
    end
    add_index :stored_flights, [:marketing_carrier_iata, :flight_number, :departure_iata, :arrival_iata, :dept_date], :unique => true, :name => :index_stored_flights
  end
end
