class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  before_create :set_first_session_action
  has_and_belongs_to_many :friends, 
    class_name: "User", 
    join_table: :friendships, 
    foreign_key: :user_id, 
    association_foreign_key: :friend_user_id
  has_many :subscriptions
  has_many :entry_actions
  validates_uniqueness_of :username
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def set_first_session_action
    self.previous_session_last_action = Time.now
    self.last_session_last_action = Time.now
  end
end
