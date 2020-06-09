class RemoveOldUnharvestedEntries < ActiveRecord::Migration[5.1]
  def change
    old_entries = Entry.where("created_at < ?", 1.year.ago)
    unused_entries = []

    old_entries.each do |e|
      if e.entry_actions == []
        unused_entries.push(e)
      end
    end

    Entry.delete unused_entries.map { |u| u.id }
  end
end
