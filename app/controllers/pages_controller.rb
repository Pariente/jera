class PagesController < ApplicationController

  require 'feedjira'
  require 'open-uri'
  include ApplicationHelper

  def fresh
    @fresh = fresh_entries(current_user)
    @search = Source.ransack(params[:q])
    @load_more_count = load_more_count(@fresh)
    @fresh = @fresh.first(20)
  end

  def more
    @fresh = fresh_entries(current_user).drop(params[:index].to_i)
    @load_more_count = load_more_count(@fresh)
    @fresh = @fresh.first(20)
    respond_to do |format|
      format.js { render 'more_fresh.js.erb' }
    end
  end

  def fresh_entries(user)
    @fresh = []

    sources = []
    user.subscriptions.each do |sub|
      sources.push(Source.find(sub.source_id))
    end

    sources.each do |s|
      entries_from_this_week = s.entries_since(1.week.ago)

      entries_from_this_week.each do |e|
        if e.is_fresh?(current_user)
          @fresh.push(e)
        end
      end
    end

    @fresh = @fresh.sort_by {|entry| entry.created_at}.reverse
  end

end