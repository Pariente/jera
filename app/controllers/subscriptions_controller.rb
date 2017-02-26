class SubscriptionsController < ApplicationController

  def new
    if Subscription.where(source_id: params[:source_id], user_id: current_user.id) != []
      Subscription.where(source_id: params[:source_id], user_id: current_user.id).destroy_all
    else
      source = Source.find(params[:source_id])
      last_entry = source.entries.first
      new_entries = 0
      sub = Subscription.create(source_id: params[:source_id], user_id: current_user.id, last_entry_seen: last_entry.id, new_entries: new_entries)
      sub.save
    end
  end

end