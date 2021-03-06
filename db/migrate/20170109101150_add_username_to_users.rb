class AddUsernameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :username, :string
    add_index :users, :username, unique: true
    add_column :users, :picture, :string, default: "/images/default_user_picture.png"
  end
end
