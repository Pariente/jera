class SetDefaultHarvesedToFalse < ActiveRecord::Migration
  def change
    change_column_default(:entry_actions, :harvested, false)
  end
end
