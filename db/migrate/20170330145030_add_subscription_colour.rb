class AddSubscriptionColour < ActiveRecord::Migration
  def change
    add_column :subscriptions, :colour, :integer, default: 0
  end
end
