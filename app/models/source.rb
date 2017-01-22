class Source < ActiveRecord::Base
  has_many :subscriptions
  has_many :entries

  private

  def self.entries_since(source, date)
    Entry.where("source_id = ? AND published_date > ?", source.id, date)
  end

end
