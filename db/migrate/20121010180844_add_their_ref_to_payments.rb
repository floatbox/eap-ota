class AddTheirRefToPayments < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.string "their_ref"
    end
  end
end
