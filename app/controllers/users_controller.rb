class UsersController < ApplicationController

  def contacts
    @friends = current_user.friends
    @pending = current_user.pending_friends
    @search = ransack_params

    # RECOMMENDATIONS
    @recommendations = current_user.new_recs
    
    # RESPONSES
    @responses = current_user.new_responses

    current_user.last_time_checked_contacts = Time.now
    current_user.save
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