class SubscriptionsController < ApplicationController
  before_action :set_last_action_at

  def subscribe
    if Subscription.where(source_id: params[:source_id], user_id: current_user.id) == []
      sub = Subscription.create(source_id: params[:source_id], user_id: current_user.id, colour: params[:colour], last_time_checked: 1.week.ago, new_entries: 0)
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

  private
  def set_last_action_at
    if Time.now > (current_user.last_session_last_action + 30*60)
      current_user.previous_session_last_action = current_user.last_session_last_action
    end
    current_user.last_session_last_action = Time.now
    current_user.save
  end

end