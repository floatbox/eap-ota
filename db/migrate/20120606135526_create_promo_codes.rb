class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
      t.string :code, :null => false
      t.boolean :used, :default => false
      t.integer :order_id, :null => true
      t.string  :value

      t.timestamps
    end
  end
end
