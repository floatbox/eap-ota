class AddIndexOnTicketValidatingCarrier < ActiveRecord::Migration
  def up
    add_index :tickets, :validating_carrier
  end

  def down
    remove_index :tickets, :validating_carrier
  end
end
