class PagesController < ApplicationController
  before_action :set_last_action_at

  require 'feedjira'
  require 'open-uri'

  def fresh

    # INITIATING HARVEST
    @fresh = []
    @new = []

    # CURRENT USER'S SUBSCRIPTIONS
    subscriptions = current_user.subscriptions.all

    # ALL SOURCES TO WHICH THE USER HAS SUBSCRIBED
    sources = []
    subscriptions.each do |sub|
      sources.push(Source.find(sub.source_id))
    end

    sources.each do |s|
      since_last_week = s.entries_since(1.week.ago)
      if since_last_week.length > 30
        iterator = s.last_entries(30)
      else
        iterator = since_last_week
      end

      iterator.each do |e|
        if e.is_fresh?(current_user)
          @fresh.push(e)
        end
      end

      # iterator.each do |e|
        # if e.is_fresh?(current_user)
        #   if e.is_new?(current_user)
        #     @new.push(e)
        #   else
            # @fresh.push(e)
          # end
        # end
      # end
    end

    # SORTING FRESH AND NEW BY REVERSE CHRONOLOGICAL ORDER
    @fresh = @fresh.sort_by {|entry| entry.created_at}.reverse
    @fresh = @fresh.first(30)
    # @new = @new.sort_by {|entry| entry.created_at}.reverse

  end

  def garden
    @colour = params[:colour]
    if ['red', 'blue', 'yellow'].include?(@colour)
      @subscriptions = current_user.subscriptions.where(colour: Subscription.colours[@colour])
    else
      @subscriptions = current_user.subscriptions
    end
    array = @subscriptions.to_a.delete_if {|sub| sub.source.last_entries(1) == []}
    @subscriptions = array.sort_by {|sub| sub.source.last_entries(1).first.created_at}.reverse
  end

  def harvest
    @unread = []
    @harvested = []
    harvested = current_user.entry_actions.where(harvested: true)
    harvested = harvested.sort_by {|p| p.created_at}.reverse
    harvested.each do |h|
      if h.read
        @harvested.push(h.entry)
      else
        @unread.push(h.entry)
      end
    end
    @harvested = @harvested.first(30)
  end

  private
  def set_last_action_at
    if Time.now > (current_user.last_session_last_action + 30*60)
      current_user.previous_session_last_action = current_user.last_session_last_action
    end
    current_user.last_session_last_action = Time.now
    current_user.save
  end

end