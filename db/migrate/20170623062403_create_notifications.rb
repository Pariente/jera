class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :user
      t.datetime :last_time_checked_contacts
      t.datetime :last_time_checked_villages
      t.boolean :new_from_contacts
      t.boolean :new_from_villages
    end
    users = User.all
    users.each do |u|
      n = Notification.create(
        user_id: u.id,
        last_time_checked_contacts: Time.now,
        last_time_checked_villages: Time.now,
        new_from_contacts: false,
        new_from_villages: false)
    end
  end
end
