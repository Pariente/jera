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

  def self.dedupe
    # find all models and group them on keys which should be common
    grouped = all.group_by{|model| [model.user_id,model.source_id] }
    grouped.values.each do |duplicates|
      # the first one we want to keep right?
      first_one = duplicates.shift # or pop for last one
      # if there are any more left, they are duplicates
      # so delete all of them
      duplicates.each{|double| double.destroy} # duplicates can now be destroyed
    end
  end

  def toggle_auto_harvest
    subscription = Subscription.find(params[:subscription_id])
    subscription.toggle_auto_harvest
    redirect_to(source_path(params[:source_id]))
  end

end