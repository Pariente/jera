class AddLastTimeCheckedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_time_checked_contacts, :datetime
    add_column :users, :last_time_checked_villages, :datetime

    users = User.all
    users.each do |u|
      u.last_time_checked_contacts = Time.now
      u.last_time_checked_villages = Time.now
      u.save
    end
  end
end
