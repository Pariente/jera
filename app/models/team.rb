class Team < ActiveRecord::Base
  has_many :memberships
  enum status: [:basic, :pro]
end