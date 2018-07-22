class EntriesController < ApplicationController

  def new
    @entry = Entry.new
  end

  def create
    entry_url = params[:entry_url]
    source_url = params[:source_url]

    source = Source.find(url: source_url)
    if source == []
      source = Source.create(url: source_url)
      source.save
    end

    entry = Entry.find(url: entry_url)
    if entry == [] 
      entry = Entry.create(url: entry_url, source_id: source.id)
      entry.save
    end

    

    # Checking if entry already exists on Jera
    existing_entry = Entry.where(url: url)
    
    if existing_entry == [] # If it does not exist, create it.

      # If the source exists on Jera nevertheless
      existing_source = 

      # If the source does not exist on Jera
      source = Source.create()

    else # If it exists, select it.
      entry = existing_entry.first
      source = entry.source
    end

    # Then create an entry_action "harvested" for the current_user
    entry_action = EntryAction.create(user_id: current_user.id, entry_id: entry.id, source_id: source.id, harvested: true)

    # If the import is successful, render the harvests view
    redirect_to harvests_path
  end

end