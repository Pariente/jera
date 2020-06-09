class AddSubscriptionColour < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :colour, :integer, default: 0
  end
end
