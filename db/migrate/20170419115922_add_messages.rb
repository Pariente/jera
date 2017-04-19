class AddMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.belongs_to :user, index: true
      t.belongs_to :recommendation, index: true
      t.text :text
      t.timestamps null: false
    end
  end
end
