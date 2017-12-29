class HarvestsController < ApplicationController

  require 'feedjira'
  require 'open-uri'

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
      @harvested = @harvested.first(20)
      render :harvest
    else
      render :results
    end
  end

end