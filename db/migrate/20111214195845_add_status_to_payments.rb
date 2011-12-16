class AddStatusToPayments < ActiveRecord::Migration

  MAPPING = {
    'Authorized' => 'blocked',
    'Charged' => 'charged',
    'Refunded' => 'charged',
    'New' => 'pending',
    'PreAuthorized3DS' => 'threeds',
    'Rejected' => 'rejected',
    'Voided' => 'canceled'
  }

  def update_statuses
    MAPPING.each_pair do |from, to|
      execute "update payments set status='#{to}' where payment_status='#{from}'"
    end
    execute "update payments set status='charged' where type='CashCharge'"
    execute "update payments set status='blocked' where type='CashCharge' and charged_at is null"
  end

  def up
    add_column :payments, :status, :string
    update_statuses
    add_index :payments, :status
  end

  def down
    remove_column :payments, :status
  end
end
