class CreateSources < ActiveRecord::Migration[5.1]
  def change
    create_table :sources do |t|
      t.string :name
      t.string :url
      t.string :rss_url
      t.string :picture

      t.timestamps null: false
    end
  end
end
