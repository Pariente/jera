class HarvestsController < ApplicationController

  require 'feedjira'
  require 'open-uri'
  include ApplicationHelper

  def harvest
    @filter = params[:filter]
    @query = params[:q]

    where_params = {user_id: current_user.id, harvested: true}
    where_params[:read] = 'false' if @filter != 'all'

    @search = EntryAction.where(where_params).order(:created_at).reverse_order.ransack(@query)
    @unread_count = EntryAction.where(user_id: current_user.id, harvested: true, read: false).count
    @harvested = @search.result(distinct: true).includes(:entry).limit(20)
    @load_more_count = load_more_count(@search.result)

    render :harvest
  end

  def results
    @query = params[:q]
    @search = EntryAction.where(user_id: current_user.id, harvested: true).order(:created_at).reverse_order.ransack(@query)
    @harvested = @search.result(distinct: true).includes(:entry).limit(20)
    @load_more_count = load_more_count(@search.result)

    render :results
  end

  def more
    @harvested = []
    if params[:all] == 'true'
      @harvested = EntryAction.where(user_id: current_user.id, harvested: true)
    else
      @harvested = EntryAction.where(user_id: current_user.id, harvested: true, read: false)
    end
    @harvested = @harvested.to_a.sort_by {|p| p.created_at}.reverse
    @harvested = @harvested.drop(params[:index].to_i)
    @load_more_count = load_more_count(@harvested)
    @harvested = @harvested.first(20)
    respond_to do |format|
      format.js { render 'more_harvested.js.erb' }
    end
  end

end