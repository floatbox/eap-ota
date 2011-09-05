class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.integer  :order_id
      t.integer  :typus_user_id
      t.integer  :ticket_id
      t.string   :pnr_number
      t.string   :status
      t.string   :method, :default => 'email'
      t.string   :destination
      t.text     :comment, :null => false
      t.datetime :activate_at, :null => false

      t.timestamps
    end
  end

  def down
    drop_table :notifications
  end
end