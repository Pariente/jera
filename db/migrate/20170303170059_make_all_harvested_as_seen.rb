class MakeAllHarvestedAsSeen < ActiveRecord::Migration
  def change
    harvested = Picking.all
    harvested.each do |h|
      seen = Reading.create(user_id: h.user_id, entry_id: h.entry_id)
      seen.save
    end
  end
end