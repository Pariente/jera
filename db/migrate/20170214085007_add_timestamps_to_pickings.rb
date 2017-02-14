class AddTimestampsToPickings < ActiveRecord::Migration
  def change
    change_table :pickings do |t|
      t.timestamps
    end
    Picking.update_all created_at: Time.now
    Picking.update_all updated_at: Time.now
  end
end
