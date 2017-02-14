class PickingsController < ApplicationController
  def new
    pick = Picking.create(user_id: current_user.id, entry_id: params[:entry_id])
    pick.save
  end

  def destroy
    Picking.find(params[:id]).destroy
  end

  def index
    @pickings = current_user.pickings.sort_by {|picking| picking.created_at}.reverse
  end
end