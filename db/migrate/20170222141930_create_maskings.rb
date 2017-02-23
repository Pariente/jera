class CreateMaskings < ActiveRecord::Migration
  def change
    create_table :maskings do |t|
      t.belongs_to :user
      t.belongs_to :entry
      t.timestamps
    end
  end
end
