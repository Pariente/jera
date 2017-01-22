class CreatePickings < ActiveRecord::Migration
  def change
    create_table :pickings do |t|
      t.belongs_to :user
      t.belongs_to :entry
    end
  end
end
