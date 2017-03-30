class DropUnusedTables < ActiveRecord::Migration
  def change
    drop_table :pickings
    drop_table :readings
    drop_table :maskings
  end
end
