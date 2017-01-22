class AddColumnsToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :auto_harvest, :boolean, default: true
    add_column :subscriptions, :new_entries, :integer, default: 0
  end
end
