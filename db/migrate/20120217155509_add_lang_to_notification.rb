class AddLangToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :lang, :string
  end
end
