class PrepareSubscriptionToNew < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :last_entry_seen
    add_column :subscriptions, :last_time_checked, :datetime
    Subscription.update_all last_time_checked: Time.now
  end
end
