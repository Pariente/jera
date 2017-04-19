class AddRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.integer :user_id
      t.integer :received_id
      t.integer :team_id
      t.timestamps null: false
    end
  end
end
