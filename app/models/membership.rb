class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  enum status: [:basic, :pro]
end