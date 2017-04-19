class Membership < ActiveRecord::Base
  enum status: [:basic, :pro]
end