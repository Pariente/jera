class AddContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :friend_user_id
      t.integer :status, default: 0
    end
  end
end
