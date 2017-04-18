class FriendshipsController < ApplicationController
  before_action :set_friendship, only: [:accept, :refuse]

  def index
    @friends = current_user.friends
  end
  def ask
    friends = User.where(id: params[:id])
    if friends == []
      respond_to do |format|
        format.json { render json: 'The person you are trying to befriend does not exist.', status: '400' }
      end
    else
      if Friendship.where(user_id: current_user.id, friend_user_id: params[:id]) == []
        @friendship = Friendship.create(user_id: current_user.id, friend_user_id: params[:id], status: 0)
        @friendship.save

        respond_to do |format|
          format.json { render json: @friendship, status: '200' }
        end
      else
        respond_to do |format|
          format.json { render json: 'You have already sent a friend request to this person.', status: '409' }
        end
      end
    end
  end

  def accept
    if current_user.id != @friendship.friend_user_id
      respond_to do |format|
        format.json { render json: 'The friend request could not be found.', status: '404' }
      end
    else
      @friendship.status = 1
      @friendship.save
      respond_to do |format|
        format.json { render json: 'You have accepted the friend request.', status: '200' }
      end
    end
  end

  def refuse
    if current_user.id != @friendship.friend_user_id
      respond_to do |format|
        format.json { render json: 'The friend request could not be found.', status: '404' }
      end
    else
      @friendship.delete
      respond_to do |format|
        format.json { render json: 'You have refused the friend request.', status: '200' }
      end
    end
  end

  private
  def set_friendship
    @friendship = Friendship.find(params[:id])
  end
end