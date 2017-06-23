class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_one :notification
  has_many :subscriptions
  has_many :entry_actions
  has_many :memberships
  has_many :messages
  validates_uniqueness_of :username
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def friends
    friendships_as_requester = Friendship.where(user_id: self.id, status: 1)
    friendships_as_receiver = Friendship.where(friend_user_id: self.id, status: 1)
    friends = []
    friendships_as_requester.each do |f|
      friends.push(User.find(f.friend_user_id))
    end
    friendships_as_receiver.each do |f|
      friends.push(User.find(f.user_id))
    end
    return friends
  end

  def pending_friends
    pending_friends = []
    Friendship.where(user_id: self.id, status: 0).each do |f|
      pending_friends.push(User.find(f.friend_user_id))
    end
    return pending_friends
  end

  def is_friend_with?(user)
    self.friends.include?(user)
  end

  def send_friend_request_to?(user)
    self.pending_friends.include?(user)
  end

  def new_recs
    all_recs = Recommendation.where("receiver_id = ? AND updated_at > ?", self.id, self.notification.last_time_checked_contacts)
    recs = []
    all_recs.each do |r|
      if self.entry_actions.where(recommendation_id: r.id) == []
        recs.push(r)
      end
    end
    return recs
  end

  def new_responses
    all_recs = Recommendation.where("receiver_id = ? OR user_id = ? AND updated_at > ?", self.id, self.id, self.notification.last_time_checked_contacts)
    recs = []
    all_recs.each do |r|
      unless r.messages.length <= 1 || r.messages.last.user_id == self.id
        recs.push(r)
      end
    end
    return recs
  end

end