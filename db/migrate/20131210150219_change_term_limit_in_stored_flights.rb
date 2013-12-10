class ChangeTermLimitInStoredFlights < ActiveRecord::Migration
  def up
    change_column :stored_flights, :departure_term, :string, :limit => 5
    change_column :stored_flights, :arrival_term, :string, :limit => 5
  end

  def down
    change_column :stored_flights, :departure_term, :string, :limit => 1
    change_column :stored_flights, :arrival_term, :string, :limit => 1
  end
end
