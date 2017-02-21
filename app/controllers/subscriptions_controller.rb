class SubscriptionsController < ApplicationController

  def new
    unless Subscription.where(source_id: params[:source_id], user_id: current_user.id) != []
      source = Source.find(params[:source_id])
      last_entry = source.entries.first
      new_entries = 0
      sub = Subscription.create(source_id: params[:source_id], user_id: current_user.id, last_entry_seen: last_entry.id, new_entries: new_entries)
      sub.save
    end
  end

  def destroy
    Subscription.find(params[:id]).destroy
  end

end