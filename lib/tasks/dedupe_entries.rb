sources = Source.all
sources.each do |s|
  entries = s.entries
  entries = entries.group_by {|e| [e.title]}
  entries.values.each do |duplicates|
    last_one = duplicates.pop
    duplicates.each{|double| double.destroy}
  end
end

actions = EntryAction.all
actions.each do |a|
  if (Entry.where(id: a.user_id) == [])
    a.destroy
  end
end