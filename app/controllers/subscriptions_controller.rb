class SubscriptionsController < ApplicationController
  before_action :set_last_action_at

  def new
    if Subscription.where(source_id: params[:source_id], user_id: current_user.id) != []
      Subscription.where(source_id: params[:source_id], user_id: current_user.id).destroy_all
    else
      source = Source.find(params[:source_id])
      sub = Subscription.create(source_id: params[:source_id], user_id: current_user.id, last_time_checked: 1.week.ago, new_entries: 0)
      sub.save
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