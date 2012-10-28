class AddRejectMessageToPayments < ActiveRecord::Migration

  def up
    change_table :payments do |t|
      t.string :error_code
      t.string :error_message
    end
    execute "update payments set error_code = reject_reason"
  end

  def down
    execute "update payments set reject_reason = error_code"
    remove_column :payments, :error_message
    remove_column :payments, :error_code
  end

end
