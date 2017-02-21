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
        @fresh.push(e)
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

end