class AddEntryIdToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :entry_id, :integer
    rename_column :recommendations, :received_id, :receiver_id
  end
end
