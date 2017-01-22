class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :source

  def toggle_auto_harvest
    self.toggle :auto_harvest
    self.save
  end

end