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
      if since_last_week.length >= 30
        iterator = s.last_entries(30)
      else
        iterator = since_last_week
      end

      iterator.each do |e|
        if e.is_fresh?(current_user)
          if e.is_new?(current_user)
            @new.push(e)
          else
            @fresh.push(e)
          end
        end
      end
    end

    # SORTING FRESH AND NEW BY REVERSE CHRONOLOGICAL ORDER
    @fresh = @fresh.sort_by {|entry| entry.created_at}.reverse
    @new = @new.sort_by {|entry| entry.created_at}.reverse

  end

  def garden
    @subscriptions = current_user.subscriptions
    # @subscriptions.each do |s|
    #   all_entries = s.source.entries
    #   last_seen = Entry.find(s.last_entry_seen)
    #   last_seen_index = all_entries.index(last_seen)
    #   s.new_entries = all_entries.count - last_seen_index - 1
    # end
    # @subscriptions = @subscriptions.sort_by {|sub| sub.new_entries}.reverse
  end

  def harvests
    pickings = current_user.pickings
    @harvests = pickings.group_by {|picking| picking.created_at.to_date }
    @harvests = @harvests.sort_by {|h| h[0]}.reverse
  end

  def harvest
    date = params[:date].to_date
    if date == Date.today
      @date = "today"
    elsif date == Date.yesterday
      @date = "yesterday"
    else
      @date = date.strftime("%e %b %Y")
    end
    pickings = current_user.pickings.where(created_at: date.midnight..date.end_of_day)
    pickings = pickings.sort_by {|p| p.created_at}.reverse
    @entries = []
    pickings.each do |p|
      @entries.push(p.entry)
    end
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