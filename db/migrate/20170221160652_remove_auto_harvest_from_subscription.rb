class RemoveAutoHarvestFromSubscription < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :auto_harvest
  end
end
