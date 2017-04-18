class Friendship < ActiveRecord::Base
  enum status: [:pending, :accepted]

  def requester
    User.find(self.user_id)
  end
end