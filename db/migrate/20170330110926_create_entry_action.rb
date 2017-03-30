class CreateEntryAction < ActiveRecord::Migration
  def change
    create_table :entry_actions do |t|
      t.belongs_to :user
      t.belongs_to :entry
      t.belongs_to :source
      t.boolean :harvested, default: false
      t.boolean :masked, default: false
      t.boolean :read, default: false
      t.timestamps
    end
  end
end
