class AddIndexesOnCarrierAndAirplaneIata < ActiveRecord::Migration
  def up
    add_index :carriers, :iata
    add_index :airplanes, :iata
  end

  def down
    drop_index :airplanes, :iata
    drop_index :carriers, :iata
  end
end
