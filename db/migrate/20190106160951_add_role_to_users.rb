class AddRoleToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :role, :integer, :default => 1

    users = User.all
    users.each do |u|
      u.role = 1
    end
  end
end
