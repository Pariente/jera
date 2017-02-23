class PagesController < ApplicationController

  require 'feedjira'
  require 'open-uri'

  def fresh

    # INITIATING HARVEST
    @fresh = []

    # CURRENT USER'S SUBSCRIPTIONS
    subscriptions = current_user.subscriptions.all

    # ALL SOURCES TO WHICH THE USER HAS SUBSCRIBED
    sources = []
    subscriptions.each do |sub|
      sources.push(Source.find(sub.source_id))
    end

    sources.each do |s|
      # ADDING ENTRIES FROM LAST MONTH
      Source.entries_since(s, 1.week.ago).each do |e|
        unless e.is_masked_by_user?(current_user) || e.is_picked_by_user?(current_user)
          @fresh.push(e)
        end
      end

      # SETTING NEW ENTRIES TO ZERO FOR AUTO-HARVESTED SOURCES
      # sub = s.subscriptions.where(user: current_user).first
      # sub.new_entries = 0
      # sub.last_entry_seen = s.entries.last.id
      # sub.save
      
    end

    # SORTING HARVEST BY REVERSE CHRONOLOGICAL ORDER
    @fresh = @fresh.sort_by {|entry| entry.published_date}.reverse

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

end