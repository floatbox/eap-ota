class AddMessageToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :subject, :string
    add_column :notifications, :format, :string
    add_column :notifications, :rendered_message, :text
  end
end