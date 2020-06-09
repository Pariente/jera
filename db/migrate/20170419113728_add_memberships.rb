class AddMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.belongs_to :team, index: true
      t.belongs_to :user, index: true
      t.integer :status, default: 0
      t.timestamps null: false
    end
  end
end
