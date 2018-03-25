class HarvestsController < ApplicationController

  require 'feedjira'
  require 'open-uri'
  include ApplicationHelper

  def harvest
    @filter = params[:filter]
    @query = params[:q]

    if @filter != 'all'
      @search = current_user.entry_actions.harvested.unread.order(:created_at).reverse_order.ransack(@query)
    else
      @search = current_user.entry_actions.harvested.order(:created_at).reverse_order.ransack(@query)
    end
    @unread_count = EntryAction.where(user_id: current_user.id, harvested: true, read: false).count
    @harvested = @search.result.includes(:entry).limit(20)
    @load_more_count = load_more_count(@search.result)

    render :harvest
  end

  def results
    @query = params[:q]
    @search = current_user.entry_actions.harvested.order(:created_at).reverse_order.ransack(@query)
    @harvested = @search.result.includes(:entry).limit(20)
    @load_more_count = load_more_count(@search.result)

    render :results
  end

  def more
    @harvested = []
    if params[:all] == 'true'
      @harvested = current_user.entry_actions.harvested.order(:created_at).reverse_order.drop(params[:index].to_i)
    else
      @harvested = current_user.entry_actions.harvested.unread.order(:created_at).reverse_order.drop(params[:index].to_i)
    end
    @load_more_count = load_more_count(@harvested)
    @harvested = @harvested.first(20)
    respond_to do |format|
      format.js { render 'more_harvested.js.erb' }
    end
  end

end