class Entry < ActiveRecord::Base
  belongs_to :source
  has_many :pickings
end