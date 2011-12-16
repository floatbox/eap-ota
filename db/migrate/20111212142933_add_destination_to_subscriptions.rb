class AddDestinationToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :from_iata, :string
    add_column :subscriptions, :to_iata, :string
    add_column :subscriptions, :rt, :boolean
  end
end
