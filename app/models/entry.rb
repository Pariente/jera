class Entry < ActiveRecord::Base
  belongs_to :source
  has_many :pickings

  def is_picked_by_user?(current_user)
    existing_picking = Picking.where(user_id: current_user.id, entry_id: self.id)
    existing_picking != []
  end

  def is_masked_by_user?(current_user)
    existing_masking = Masking.where(user_id: current_user.id, entry_id: self.id)
    existing_masking != []
  end

  def is_read_by_user?(current_user)
    existing_reading = Reading.where(user_id: current_user.id, entry_id: self.id)
    existing_reading != []
  end

  def picked_by_user(current_user)
    Picking.where(user_id: current_user.id, entry_id: self.id).first
  end

  def is_new?(current_user)
    source = Source.find(self.source_id)
    sub = Subscription.where(source_id: source.id, user_id: current_user.id).first
    unless sub == nil
      (self.created_at > current_user.previous_session_last_action) && !self.is_masked_by_user?(current_user) && !self.is_picked_by_user?(current_user) && (sub.last_time_checked < self.created_at) 
    end
  end

  def is_fresh?(current_user)
    !self.is_masked_by_user?(current_user) && !self.is_picked_by_user?(current_user) && (self.created_at > 1.week.ago)
  end
end