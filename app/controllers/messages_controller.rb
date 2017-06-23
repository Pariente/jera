class MessagesController < ApplicationController

  def new
    rec = Recommendation.find(params[:rec_id])
    receiver = User.find(rec.receiver_id)
    e = Entry.find(rec.entry.id)

    if (rec.receiver_id == current_user.id || rec.user_id == current_user.id) && (params[:text] != "")
      @message = Message.create(
        user_id: current_user.id,
        recommendation_id: rec.id,
        text: params[:text])
      
      
      receiver.notification.new_from_contacts = true

      rec.updated_at = Time.now
      rec.save

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