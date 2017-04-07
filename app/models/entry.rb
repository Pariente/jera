class Entry < ActiveRecord::Base
  belongs_to :source
  has_many :entry_actions

  def is_harvested_by_user?(current_user)
    action = EntryAction.where(user_id: current_user.id, entry_id: self.id)
    action != [] && action.first.harvested
  end

  def is_masked_by_user?(current_user)
    action = EntryAction.where(user_id: current_user.id, entry_id: self.id)
    action != [] && action.first.masked
  end

  def is_read_by_user?(current_user)
    action = EntryAction.where(user_id: current_user.id, entry_id: self.id)
    action != [] && action.first.read
  end

  def is_new?(current_user)
    source = Source.find(self.source_id)
    sub = Subscription.where(source_id: source.id, user_id: current_user.id).first
    unless sub == nil
      (self.created_at > current_user.previous_session_last_action) && !self.is_masked_by_user?(current_user) && !self.is_harvested_by_user?(current_user) && !self.is_read_by_user?(current_user) && (sub.last_time_checked < self.created_at) 
    end
  end

  def is_fresh?(current_user)
    !self.is_masked_by_user?(current_user) && !self.is_harvested_by_user?(current_user) && (self.created_at > 1.week.ago)
  end

  def self.dedupe
    # find all models and group them on keys which should be common
    grouped = all.group_by{|model| [model.media_url] }
    grouped.values.each do |duplicates|
      # the first one we want to keep right?
      first_one = duplicates.shift # or pop for last one
      # if there are any more left, they are duplicates
      # so delete all of them
      duplicates.each{|double| double.destroy} # duplicates can now be destroyed
    end
  end
end