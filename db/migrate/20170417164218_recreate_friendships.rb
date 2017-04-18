class RecreateFriendships < ActiveRecord::Migration
  def change
    drop_table :friendships
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :friend_user_id
    end

    add_index(:friendships, [:user_id, :friend_user_id], :unique => true)
    add_index(:friendships, [:friend_user_id, :user_id], :unique => true)
    add_column :friendships, :status, :integer, default: 0
  end
end
