class SourcesController < ApplicationController
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  def index
    @sources = Source.all
  end

  def show
    @harvest = []
    feed = Feedjira::Feed.fetch_and_parse @source.rss_url

    # CREATING ENTRIES IF THEY ARE NOT YET IN DATABASE
    feed.entries.each do |e|
      if (Entry.where(media_url: e.media_url) == [])
        Entry.create(
          source_id: s.id, 
          title: e.title,
          content: e.content,
          published_date: e.published, 
          media_url: e.media_url,
          thumbnail_url: e.media_thumbnail_url)
      end
    end

    Source.entries_since(@source, 1.year.ago).each do |e|
      @harvest.push(e)
    end

    # SORTING HARVEST BY REVERSE CHRONOLOGICAL ORDER
    @harvest = @harvest.sort_by {|entry| entry.published_date}.reverse
    @sub = @source.subscriptions.where(user: current_user).first
    @sub.new_entries = 0
    @sub.last_entry_seen = @source.entries.last.id
    @sub.save
  end

  def new
    @source = Source.new
  end

  def edit
  end

  def create
    @source = Source.new(source_params)
    @source.users << current_user

    respond_to do |format|
      if @source.save
        format.html { redirect_to @source, notice: 'Source was successfully created.' }
        format.json { render :show, status: :created, location: @source }
      else
        format.html { render :new }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @source.update(source_params)
        format.html { redirect_to @source, notice: 'Source was successfully updated.' }
        format.json { render :show, status: :ok, location: @source }
      else
        format.html { render :edit }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @source.destroy
    respond_to do |format|
      format.html { redirect_to sources_url, notice: 'Source was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_source
      @source = Source.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_params
      params.require(:source).permit(:name, :url)
    end
end
