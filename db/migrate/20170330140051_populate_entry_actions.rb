class PopulateEntryActions < ActiveRecord::Migration
  def change
    pickings = Picking.all
    readings = Reading.all
    maskings = Masking.all

    pickings.each do |p|
      entry = Entry.find(p.entry_id)
      source_id = entry.source.id
      action = EntryAction.create(user_id: p.user_id, entry_id: entry.id, source_id: source_id, harvested: true)
      action.save
    end

    readings.each do |r|
      entry = Entry.find(r.entry_id)
      source_id = entry.source.id
      existing_action = EntryAction.where(user_id: r.user_id, entry_id: entry.id)
      if existing_action == []
        action = EntryAction.create(user_id: r.user_id, entry_id: entry.id, source_id: source_id, read: true)
        action.save
      else
        existing_action.first.read = true
        existing_action.first.save
      end
    end

    maskings.each do |m|
      entry = Entry.find(m.entry_id)
      source_id = entry.source.id
      existing_action = EntryAction.where(user_id: m.user_id, entry_id: entry.id)
      if existing_action == []
        action = EntryAction.create(user_id: m.user_id, entry_id: entry.id, source_id: source_id, masked: true)
        action.save
      else
        existing_action.first.masked = true
        existing_action.first.save
      end
    end

  end
end
