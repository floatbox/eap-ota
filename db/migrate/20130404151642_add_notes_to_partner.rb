class AddNotesToPartner < ActiveRecord::Migration
  def change
    change_table :partners do |t|
      t.text :notes
    end
  end
end
