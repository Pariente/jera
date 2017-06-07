class EntryAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  belongs_to :source

  def recommendation
    if self.recommendation_id != nil
      return Recommendation.find(self.recommendation_id)
    end
  end
end