class ChangeSources < ActiveRecord::Migration
  def change
    add_column :sources, :rss_url, :string
    add_column :sources, :picture, :string
  end
end
