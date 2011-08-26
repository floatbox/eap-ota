class CreateFlightGroups < ActiveRecord::Migration
  def change
    create_table :flight_groups do |t|
      t.text :code

      t.timestamps
    end
  end
end
