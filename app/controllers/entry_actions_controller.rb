class EntryActionsController < ApplicationController
  
  def more_not_seen
    @actions = []
    @actions = EntryAction.where(user_id: current_user.id, harvested: true, read: false)
    @actions = @actions.to_a.sort_by {|p| p.created_at}.reverse
    @actions = @actions.drop(params[:index].to_i).first(20)
    respond_to do |format|
      format.js { render 'more_entry_action.js.erb' }
    end
  end

  def more_all
    @actions = []
    @actions = EntryAction.where(user_id: current_user.id, harvested: true)
    @actions = @actions.to_a.sort_by {|p| p.created_at}.reverse
    @actions = @actions.drop(params[:index].to_i).first(20)
    respond_to do |format|
      format.js { render 'more_entry_action.js.erb' }
    end
  end

  def harvest
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id], recommendation_id: params[:recommendation_id])
    # CHECKING IF ACTION EXISTS
    if existing_action == []
      # IF IT DOESN'T, CREATE AND SAVE IT WITH "HARVESTED" AS TRUE
      entry = Entry.find(params[:entry_id])
      source = entry.source
      action = EntryAction.create(user_id: current_user.id, entry_id: params[:entry_id], source_id: source.id, harvested: true, recommendation_id: params[:recommendation_id])
      action.save
    else
      # IF SO, TURN THE "HARVESTED" TO TRUE
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
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id], recommendation_id: params[:recommendation_id])
    unless existing_action == []
      if existing_action.first.read
        existing_action.first.harvested = false
        existing_action.first.save
      else
        existing_action.destroy_all
      end
    end

    respond_to do |format|
      format.json { render json: existing_action, status: '200' }
    end
  end

  def mask
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id], recommendation_id: params[:recommendation_id])
    # CHECKING IF ACTION EXISTS
    if existing_action == []
      # IF IT DOESN'T, CREATE AND SAVE IT WITH "MASKED" AS TRUE
      entry = Entry.find(params[:entry_id])
      source = entry.source
      action = EntryAction.create(user_id: current_user.id, entry_id: params[:entry_id], source_id: source.id, masked: true, recommendation_id: params[:recommendation_id])
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
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id], recommendation_id: params[:recommendation_id])
    unless existing_action == []
      if existing_action.first.read
        existing_action.first.masked = false
        existing_action.first.save
      else
        existing_action.destroy_all
      end
    end

    respond_to do |format|
      format.json { render json: existing_action, status: '200' }
    end
  end

  def read
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id])
    # CHECKING IF ACTION EXISTS
    if existing_action == []
      # IF IT DOESN'T, CREATE AND SAVE IT WITH "READ" AS TRUE
      entry = Entry.find(params[:entry_id])
      source = entry.source
      action = EntryAction.create(user_id: current_user.id, entry_id: params[:entry_id], source_id: source.id, read: true, recommendation_id: params[:recommendation_id])
      action.save
    else
      # IF IT DOES, UPDATE THE VALUE OF "READ" TO TRUE
      existing_action.each do |a|
        a.read = true
        a.save
      end
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
    existing_action = EntryAction.where(user_id: current_user.id, entry_id: params[:entry_id])
    unless existing_action == []
      existing_action.each do |a|
        a.read = false
        a.save
      end
    end

    respond_to do |format|
      format.json { render json: existing_action, status: '200' }
    end
  end

  def results
    @search = ransack_params
    @actions  = ransack_result
    @actions = EntryAction.new
    respond_to do |format|
      format.html { render 'index.html.erb' }
    end
  end

  def destroy
    EntryAction.find(params[:id]).destroy
    # CLEARING THIS FRAGMENT FROM CACHE
    e = Entry.find(params[:entry_id])
    ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
  end

  private
    def ransack_params
      EntryAction.where().ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct: true)
    end
    def source_params
      params.require(:entry_action).permit(:user_id, :harvested, :read, :masked)
    end
end