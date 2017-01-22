class PagesController < ApplicationController

  require 'feedjira'

  def harvest

    # INITIATING HARVEST
    @harvest = []

    # CURRENT USER'S SUBSCRIPTIONS
    subscriptions = current_user.subscriptions.where(auto_harvest: true)

    # ALL SOURCES TO WHICH THE USER HAS SUBSCRIBED
    sources = []
    subscriptions.each do |sub|
      sources.push(Source.find(sub.source_id))
    end

    sources.each do |s|
      # FETCHING FEED
      feed = Feedjira::Feed.fetch_and_parse s.rss_url

      # CREATING ENTRIES IF THEY ARE NOT YET IN DATABASE
      feed.entries.each do |e|
        if (Entry.where(media_url: e.media_url) == [])
          Entry.create(
            source_id: s.id, 
            title: e.title,
            content: e.content,
            published_date: e.published, 
            media_url: e.media_url,
            thumbnail_url: e.media_thumbnail_url)
        end
      end

      # SETTING NEW ENTRIES TO ZERO FOR AUTO-HARVESTED SOURCES
      sub = s.subscriptions.where(user: current_user).first
      sub.new_entries = 0
      sub.last_entry_seen = s.entries.last.id
      sub.save

      # ADDING ENTRIES FROM LAST MONTH
      Source.entries_since(s, 1.month.ago).each do |e|
        @harvest.push(e)
      end

    end

    # SORTING HARVEST BY REVERSE CHRONOLOGICAL ORDER
    @harvest = @harvest.sort_by {|entry| entry.published_date}.reverse

  end

  def garden
    @subscriptions = current_user.subscriptions
    @subscriptions.each do |s|
      all_entries = s.source.entries
      last_seen = Entry.find(s.last_entry_seen)
      last_seen_index = all_entries.index(last_seen)
      s.new_entries = all_entries.count - last_seen_index - 1
    end
    @subscriptions = @subscriptions.sort_by {|sub| sub.new_entries}.reverse
  end

end