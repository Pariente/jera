class RecommendationsController < ApplicationController

  def new
    @entry = Entry.find(params[:entry_id])
    @recommendation = Recommendation.new()
    @contacts = current_user.friends
    @memberships = current_user.memberships
    @search = ransack_params
    unless params[:q] == nil
      @contacts = []
      ransack_result.each do |u|
        if current_user.is_friend_with?(u)
          @contacts.push(u)
        end
      end
    end
  end

  def recommend_to_friend
    if Recommendation.where(user_id: current_user.id, receiver_id: params[:receiver_id], entry_id: params[:entry_id]) == []
      if current_user.is_friend_with?(User.find(params[:receiver_id]))
        @reco = Recommendation.create(
          user_id: current_user.id,
          receiver_id: params[:receiver_id],
          entry_id: params[:entry_id])

        @message = Message.create(
          user_id: current_user.id,
          recommendation_id: @reco.id,
          text: params[:message])

        receiver_notification = User.find(params[:receiver_id]).notification
        receiver_notification.new_from_contacts = true
        receiver_notification.save

        respond_to do |format|
          format.json { render json: [@reco, @message], status: '200' }
        end
      else
        respond_to do |format|
          format.json { render json: 'You are not friend with this person. You cannot recommend fruits to her/him.', status: '401' }
        end
      end
    else
      respond_to do |format|
        format.json { render json: 'You have already recommended this fruit to your friend.', status: '401' }
      end
    end
  end

  def recommend_to_team
    team = Team.find(params[:team_id])
    if team.users.include?(current_user)
      @reco = Recommendation.create(user_id: current_user.id, team_id: params[:team_id], entry_id: params[:entry_id])
      @reco.save
      respond_to do |format|
        format.json { render json: @reco, status: '200' }
      end
    else
      respond_to do |format|
        format.json { render json: 'You are not a member of this team. You cannot recommend fruits to it.', status: '401' }
      end
    end
  end

  private
    def ransack_params
      User.ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct: true)
    end
end