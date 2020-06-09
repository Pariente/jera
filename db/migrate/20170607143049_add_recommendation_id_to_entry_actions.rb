class AddRecommendationIdToEntryActions < ActiveRecord::Migration[5.1]
  def change
    add_column :entry_actions, :recommendation_id, :integer
  end
end
