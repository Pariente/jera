class EntryAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  belongs_to :source

  scope :harvested, -> {where harvested: true}
  scope :unread, -> {where read: false}

  def recommendation
    if self.recommendation_id != nil
      return Recommendation.find(self.recommendation_id)
    end
  end
end