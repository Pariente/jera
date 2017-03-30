class EntryActionsController < ApplicationController
  def harvest
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id])
    # CHECKING IF ACTION EXISTS
    if existing_action == []
      # IF IT DOESN'T, CREATE AND SAVE IT WITH "HARVESTED" AS TRUE
      entry = Entry.find(params[:entry_id])
      source = entry.source
      action = EntryAction.create(user_id: current_user.id, entry_id: params[:entry_id], source_id: source.id, harvested: true)
      action.save
    else
      # IF SO, THEN TURN THE "HARVESTED" TO FALSE
      existing_action.first.harvested = true
      existing_action.first.save
    end

    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})

    respond_to do |format|
      if existing_action == []
        format.json { render json: action, status: '200' }
      else
        format.json { render json: existing_action, status: '200' }
      end
    end
  end

  def unharvest
    action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id])
    unless action == []
      if action.first.read
        action.first.harvested = false
        action.first.save
      else
        action.destroy_all
      end
    end

    respond_to do |format|
      format.json { render json: action, status: '200' }
    end
  end

  def mask
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id])
    # CHECKING IF ACTION EXISTS
    if existing_action == []
      # IF IT DOESN'T, CREATE AND SAVE IT WITH "MASKED" AS TRUE
      entry = Entry.find(params[:entry_id])
      source = entry.source
      action = EntryAction.create(user_id: current_user.id, entry_id: params[:entry_id], source_id: source.id, masked: true)
      action.save
    else
      # IF IT DOES, UPDATE THE VALUE OF "MASKED" TO TRUE
      existing_action.first.masked = true
      existing_action.first.save
    end

    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})

    respond_to do |format|
      if existing_action == []
        format.json { render json: action, status: '200' }
      else
        format.json { render json: existing_action, status: '200' }
      end
    end
  end

  def unmask
    action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id])
    unless action == []
      if action.first.read
        action.first.masked = false
        action.first.save
      else
        action.destroy_all
      end
    end

    respond_to do |format|
      format.json { render json: action, status: '200' }
    end
  end

  def read
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id])
    # CHECKING IF ACTION EXISTS
    if existing_action == []
      # IF IT DOESN'T, CREATE AND SAVE IT WITH "READ" AS TRUE
      entry = Entry.find(params[:entry_id])
      source = entry.source
      action = EntryAction.create(user_id: current_user.id, entry_id: params[:entry_id], source_id: source.id, read: true)
      action.save
    else
      # IF IT DOES, UPDATE THE VALUE OF "READ" TO TRUE
      existing_action.first.read = true
      existing_action.first.save
    end

    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})

    respond_to do |format|
      if existing_action == []
        format.json { render json: action, status: '200' }
      else
        format.json { render json: existing_action, status: '200' }
      end
    end
  end

  def unread
    action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id])
    unless action == []
      action.first.read = false
      action.first.save
    end

    respond_to do |format|
      format.json { render json: action, status: '200' }
    end
  end

  def destroy
    EntryAction.find(params[:id]).destroy
    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
  end
end