class AddIpToPayments < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.string :ip
    end
  end
end
