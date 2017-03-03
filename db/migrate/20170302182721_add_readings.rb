class AddReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.belongs_to :user
      t.belongs_to :entry
      t.timestamps
    end
  end
end
