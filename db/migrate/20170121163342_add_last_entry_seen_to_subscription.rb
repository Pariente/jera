class AddLastEntrySeenToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :last_entry_seen, :integer
  end
end
