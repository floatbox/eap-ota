class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.string :number
      t.decimal :price_fare, :precision => 9, :scale => 2, :default => 0, :null => false
      t.string :commission_subagent
      t.decimal :price_tax, :precision => 9, :scale => 2, :default => 0, :null => false
      t.decimal :price_share, :precision => 9, :scale => 2, :default => 0, :null => false
      t.decimal :price_consolidator_markup, :precision => 9, :scale => 2, :default => 0, :null => false
      t.integer :order_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end

