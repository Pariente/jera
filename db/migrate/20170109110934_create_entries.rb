class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.belongs_to :source, index: true
      t.string :title
      t.text :content
      t.date :published_date
      t.string :media_url
      t.string :thumbnail_url
      t.timestamps
    end
  end
end
