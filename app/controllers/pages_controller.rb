class PagesController < ApplicationController

  require 'feedjira'
  require 'open-uri'

  def fresh
    # INITIATING HARVEST
    @fresh = []
    @new = []
    @search = ransack_params

    # CURRENT USER'S SUBSCRIPTIONS
    subscriptions = current_user.subscriptions.all

    # THE SOURCES TO WHICH THE USER HAS SUBSCRIBED
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
    end

    # SORTING FRESH AND NEW BY REVERSE CHRONOLOGICAL ORDER
    @fresh = @fresh.sort_by {|entry| entry.created_at}.reverse
    @fresh = @fresh.first(30)

    # RECOMMENDATIONS
    @recommendations = current_user.recommendations_received

    # RESPONSES
    @responses = current_user.recommendations_with_responses

    # PENDING FRIEND REQUESTS
    @friend_requests = Friendship.where(friend_user_id: current_user.id, status: 'pending')

  end

  def garden
    @search = ransack_params
    @subscriptions = current_user.subscriptions
    array = @subscriptions.to_a.delete_if {|sub| sub.source.last_entries(1) == []}
    @subscriptions = array.sort_by {|sub| sub.source.last_entries(1).first.created_at}.reverse
  end

  def harvest
    @filter = params[:filter]
    @search = ransack_params
    @harvested = []
    @unread_count = 0

    unread = []
    harvested = []


    # ALL HARVESTED ENTRIES BY USER
    harvested_all = current_user.entry_actions.where(harvested: true)
    harvested_all = harvested_all.sort_by {|p| p.created_at}.reverse

    # ALL HARVESTED ENTRIES THE USER HAS NOT READ YET
    harvested_all.each do |h|
      unless h.read
        unread.push(h)
      end
    end

    # NUMBER OF HARVESTED ENTRIES THE USER HAS NOT READ YET
    @unread_count = unread.count

    # FILTERING RESULTS
    if @filter == 'unseen'
      @harvested = unread
    else
      @harvested = harvested_all
    end

    # INFORMING THE VIEW OF THE NUMBER OF REMAINING ACTIONS
    @remaining_actions_count = 0
    if @harvested.count > 20
      @remaining_actions_count = @harvested.count - 20
    end

    @harvested = @harvested.first(20)
  end

  private
    def ransack_params
      Source.ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct: true)
    end
end