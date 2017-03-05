class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  before_create :set_first_session_action
  has_many :subscriptions
  has_many :pickings
  has_many :readings
  validates_uniqueness_of :username
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def set_first_session_action
     self.last_session_last_action = Time.now
  end
end
