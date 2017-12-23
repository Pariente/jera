class PagesController < ApplicationController

  require 'feedjira'
  require 'open-uri'

  def fresh
    # INITIATING HARVEST
    @fresh = []
    @new = []
    @search = Source.ransack(params[:q])

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

    # PENDING FRIEND REQUESTS
    @friend_requests = Friendship.where(friend_user_id: current_user.id, status: 'pending')

  end

  def garden
    @search = Source.ransack(params[:q])
    @subscriptions = current_user.subscriptions
    array = @subscriptions.to_a.delete_if {|sub| sub.source.last_entries(1) == []}
    @subscriptions = array.sort_by {|sub| sub.source.last_entries(1).first.created_at}.reverse
  end

  # def contact
  #   @user = User.find(params[:id])
  #   @recs = current_user.recs_with(@user)
  #   @search = ransack_params
  # end

end