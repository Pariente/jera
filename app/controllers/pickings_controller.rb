class PickingsController < ApplicationController
  def new
    # CHECKING IF PICKING EXISTS
    existing_picking = Picking.where(user_id: current_user.id, entry_id: params[:entry_id])
    if existing_picking == []
      # IF IT DOES NOT, CREATE AND SAVE IT
      pick = Picking.create(user_id: current_user.id, entry_id: params[:entry_id])
      pick.save
      # CLEARING CACHE, BUT NEED TO FIND OUT HOW TO ONLY EXPIRE THE CONCERNED FRAGMENT
      e = Entry.find(params[:entry_id])
      ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
    end
  end

  def destroy
    Picking.find(params[:id]).destroy
    # CLEARING CACHE, BUT NEED TO FIND OUT HOW TO ONLY EXPIRE THE CONCERNED FRAGMENT
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
  end

  def index
    @pickings = current_user.pickings.sort_by {|picking| picking.created_at}.reverse
  end
end