class ReadingsController < ApplicationController
  def new
    existing_reading = Reading.where(user_id: current_user.id, entry: params[:entry_id])
    if existing_reading == []
      reading = Reading.create(user_id: current_user.id, entry_id: params[:entry_id])
      reading.save
      # CLEARING THIS FRAGMENT FROM CACHE
      e = Entry.find(params[:entry_id])
      ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
    end
  end
end