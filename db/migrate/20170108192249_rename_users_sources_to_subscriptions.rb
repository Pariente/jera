class RenameUsersSourcesToSubscriptions < ActiveRecord::Migration
  def change
    rename_table :users_sources, :subscriptions
  end 
end
