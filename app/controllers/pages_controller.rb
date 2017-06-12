class PagesController < ApplicationController

  require 'feedjira'
  require 'open-uri'

  def fresh
    @colour = params[:colour]
    # INITIATING HARVEST
    @fresh = []
    @new = []
    @search = ransack_params

    # CURRENT USER'S SUBSCRIPTIONS
    subscriptions = current_user.subscriptions.all

    if @colour == 'red'
      array = subscriptions.to_a.delete_if {|sub| !sub.red?}
      subscriptions = array
    elsif @colour == 'blue'
      array = subscriptions.to_a.delete_if {|sub| !sub.blue?}
      subscriptions = array
    elsif @colour == 'yellow'
      array = subscriptions.to_a.delete_if {|sub| !sub.yellow?}
      subscriptions = array
    end

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
    @colour = params[:colour]
    @unread = []
    @harvested = []
    @search = ransack_params
    subscriptions = current_user.subscriptions.all
    array = []
    sources = []

    if @colour == 'red'
      array = subscriptions.to_a.delete_if {|sub| !sub.red?}
    elsif @colour == 'blue'
      array = subscriptions.to_a.delete_if {|sub| !sub.blue?}
    elsif @colour == 'yellow'
      array = subscriptions.to_a.delete_if {|sub| !sub.yellow?}
    else
      array = subscriptions
    end

    array.each do |sub|
      sources.push(sub.source)
    end

    harvested = current_user.entry_actions.where(harvested: true)
    harvested = harvested.sort_by {|p| p.updated_at}.reverse
    harvested.each do |h|
      if h.read
        @harvested.push(h)
      else
        @unread.push(h)
      end
    end
    if @unread.count >= 30
      @harvested = []
    else
      @harvested = @harvested.first(30 - @unread.count)
    end
  end

  private
    def ransack_params
      Source.ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct: true)
    end
end