class PickingsController < ApplicationController
  def new
    existing_picking = Picking.where(user_id: current_user.id, entry_id: params[:entry_id])
    
    # CHECKING IF PICKING EXISTS
    if existing_picking == []

      # IF IT DOES NOT, CREATE AND SAVE IT
      pick = Picking.create(user_id: current_user.id, entry_id: params[:entry_id])
      pick.save
    else

      # IF IT DOES, DESTROY IT
      existing_picking.destroy_all
    end

    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
  end

  def destroy
    Picking.find(params[:id]).destroy
    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
  end

  def index
    @pickings = current_user.pickings.sort_by {|picking| picking.created_at}.reverse
  end
end