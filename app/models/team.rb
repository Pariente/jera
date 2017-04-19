class Team < ActiveRecord::Base
  enum status: [:basic, :pro]
end