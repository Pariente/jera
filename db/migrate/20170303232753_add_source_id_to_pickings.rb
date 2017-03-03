class AddSourceIdToPickings < ActiveRecord::Migration
  def change
    add_reference :pickings, :source, index: true, foreign_key: true
    pickings = Picking.all
    pickings.each do |p|
      p.source_id = p.entry.source.id
      p.save
    end
  end
end
