class HarvestsController < ApplicationController

  require 'feedjira'
  require 'open-uri'
  include ApplicationHelper

  def harvest
    @filter = params[:filter]
    @query = params[:q]
    @search = EntryAction.where(user_id: current_user.id, harvested: true).ransack(@query)
    @harvested = @search.result(distinct: true).includes(:entry)
    @unread_count = 0

    unread = []


    # ALL HARVESTED ENTRIES BY USER
    @harvested = @harvested.sort_by {|p| p.created_at}.reverse

    # ALL HARVESTED ENTRIES THE USER HAS NOT READ YET
    @harvested.each do |h|
      unless h.read
        unread.push(h)
      end
    end

    # NUMBER OF HARVESTED ENTRIES THE USER HAS NOT READ YET
    @unread_count = unread.count

    # RENDERING NORMAL HARVEST VIEW, OR RESULTS VIEW IF USER MADE A SEARCH
    if @query == nil
      # FILTERING RESULTS
      if @filter != 'all'
        @harvested = unread
      end
      @load_more_count = load_more_count(@harvested)
      @harvested = @harvested.first(20)
      render :harvest
    else
      render :results
    end
  end

  def more
    @harvested = []
    if params[:all] == 'true'
      @harvested = EntryAction.where(user_id: current_user.id, harvested: true)
    else
      @harvested = EntryAction.where(user_id: current_user.id, harvested: true, read: false)
    end
    @harvested = @harvested.to_a.sort_by {|p| p.created_at}.reverse
    @harvested = @harvested.drop(params[:index].to_i).first(20)
    @load_more_count = load_more_count(@harvested)
    respond_to do |format|
      format.js { render 'more_harvested.js.erb' }
    end
  end

end