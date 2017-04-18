class SubscriptionsController < ApplicationController

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