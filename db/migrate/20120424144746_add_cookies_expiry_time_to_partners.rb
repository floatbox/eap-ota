class AddCookiesExpiryTimeToPartners < ActiveRecord::Migration
  def self.up
    change_table :partners do |t|
      t.integer :cookies_expiry_time
    end
  end

  def self.down
    remove_column :partners, :cookies_expiry_time
  end
end
