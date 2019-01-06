class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer, :default => 1

    users = User.all
    users.each do |u|
      u.role = 1
    end
  end
end
