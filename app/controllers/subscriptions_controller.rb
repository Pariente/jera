class SubscriptionsController < ApplicationController

  def index
    @search = Source.ransack(params[:q])
    @subscriptions = current_user.subscriptions
    array = @subscriptions.to_a.delete_if {|sub| sub.source.last_entries(1) == []}
    @subscriptions = array.sort_by {|sub| sub.source.last_entries(1).first.created_at}.reverse
  end

  def subscribe
    if Subscription.where(source_id: params[:source_id], user_id: current_user.id) == []
      sub = Subscription.create(source_id: params[:source_id], user_id: current_user.id, colour: params[:colour])
      sub.save
    end

    respond_to do |format|
      format.json { render json: sub, status: '200' }
    end
  end

  def update
    subs = Subscription.where(source_id: params[:source_id], user_id: current_user.id)
    unless subs == []
      sub = subs.first
      sub.colour = params[:colour]
      sub.save
    end

    respond_to do |format|
      format.json { render json: sub, status: '200' }
    end
  end

  def unsubscribe
    subs = Subscription.where(source_id: params[:source_id], user_id: current_user.id)
    unless subs == []
      subs.destroy_all
    end

    respond_to do |format|
      format.json { render json: 'Unsubscribed.', status: '200' }
    end
  end

end