class MessagesController < ApplicationController

  def new
    rec = Recommendation.find(params[:rec_id])
    if (rec.receiver_id == current_user.id || rec.user_id == current_user.id) && (params[:text] != "")
      @message = Message.create(user_id: current_user.id, recommendation_id: rec.id, text: params[:text])
      @message.save
      rec.updated_at = Time.now
      rec.save
      # if rec.entry.is_harvested_by_user?(current_user)
      #   actions = EntryAction.where(entry_id: rec.entry.id, user_id: current_user.id)
      #   actions.first.updated_at = Time.now
      #   actions.first.save
      # end
      e = Entry.find(rec.entry.id)
      ActionController::Base.new.expire_fragment(%r{entry-#{e.id}/*})
      respond_to do |format|
        format.json { render json: [@message], status: '200' }
      end
    else
      respond_to do |format|
        format.json { render json: 'You cannot participate in a discussion to which you have not been invited.', status: '401' }
      end
    end
  end
end