class PrepareUsersToNew < ActiveRecord::Migration
  def change
    add_column :users, :previous_session_last_action, :datetime
    add_column :users, :last_session_last_action, :datetime
    User.update_all last_session_last_action: Time.now
    User.update_all previous_session_last_action: Time.now
  end
end
