class Recommendation < ActiveRecord::Base
  has_many :messages
  belongs_to :entry
end