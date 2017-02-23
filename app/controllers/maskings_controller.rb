class MaskingsController < ApplicationController
  def new
    existing_masking = Masking.where(user_id: current_user.id, entry_id: params[:entry_id])
    
    # CHECKING IF PICKING EXISTS
    if existing_masking == []

      # IF IT DOES NOT, CREATE AND SAVE IT
      mask = Masking.create(user_id: current_user.id, entry_id: params[:entry_id])
      mask.save
    else

      # IF IT DOES, DESTROY IT
      existing_masking.destroy_all
    end

    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
  end

  def destroy
    Masking.find(params[:id]).destroy
    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
  end
end