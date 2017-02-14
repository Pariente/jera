class Entry < ActiveRecord::Base
  belongs_to :source
  has_many :pickings

  def is_picked_by_user?(current_user)
    existing_picking = Picking.where(user_id: current_user.id, entry_id: self.id)
    existing_picking != []
  end

  def picked_by_user(current_user)
    Picking.where(user_id: current_user.id, entry_id: self.id).first
  end
end