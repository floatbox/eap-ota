class ReCreateNotifications < ActiveRecord::Migration
  def up
    drop_table :notifications if self.table_exists?("notifications")
    create_table :notifications do |t|
      t.integer  :order_id
      t.integer  :typus_user_id
      t.integer  :ticket_id
      t.string   :pnr_number
      t.boolean  :attach_pnr, :default => true
      t.string   :status, :null => false, :default => ''
      t.string   :method, :null => false, :default => 'email'
      t.string   :destination
      t.text     :comment
      t.datetime :activate_from
      t.datetime :sent_at

      t.timestamps
    end
  end

  def down
    drop_table :notifications
  end
end
