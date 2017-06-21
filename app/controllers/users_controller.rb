class UsersController < ApplicationController

  def contacts
    @friends = current_user.friends
    @pending = current_user.pending_friends
    @search = ransack_params

    # RECOMMENDATIONS
    @recommendations = current_user.recommendations_received
    
    # RESPONSES
    @responses = current_user.recommendations_with_responses
  end

  def results
    @search = ransack_params
    @results  = ransack_result
    if @results.include?(current_user)
      @results.to_a.delete(current_user)
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