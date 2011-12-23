class AddChargedOnToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :charged_on, :date
    # в базе все чаржнутые платежи были сделаны в +4 GMT
    execute "update payments set charged_on = date(addtime(charged_at, '4:00:00'))"
  end

  def down
    remove_column :payments, :charged_on
  end
end
