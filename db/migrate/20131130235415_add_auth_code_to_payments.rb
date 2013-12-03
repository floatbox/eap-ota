class AddAuthCodeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :auth_code, :string
  end
end
