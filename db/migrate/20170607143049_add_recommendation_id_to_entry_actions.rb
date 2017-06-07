class AddRecommendationIdToEntryActions < ActiveRecord::Migration
  def change
    add_column :entry_actions, :recommendation_id, :integer
  end
end
