class EntryAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  belongs_to :source
end