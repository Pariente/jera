class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :subscriptions
  has_many :entry_actions
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
end
