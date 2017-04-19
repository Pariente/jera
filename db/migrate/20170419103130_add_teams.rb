class AddTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :status, default: 0
      t.string :picture
      t.timestamps null: false
    end
  end
end
