class SourcesController < ApplicationController
  before_action :set_source, only: [:show, :edit, :update, :destroy]
  require 'open-uri'

  def top
    @sources = Source.all
    @sources = @sources.sort_by {|source| source.subscriptions.count}.reverse
    @sources = @sources.first(100)
  end

  def latest
    @sources = Source.all
    @sources = @sources.sort_by {|source| source.created_at}.reverse
    @sources = @sources.first(100)
  end

  def show
    @harvest = []

    Source.entries_since(@source, 1.year.ago).each do |e|
      @harvest.push(e)
    end

    # SORTING HARVEST BY REVERSE CHRONOLOGICAL ORDER
    @harvest = @harvest.sort_by {|entry| entry.published_date}.reverse
    
    @sub = @source.subscriptions.where(user: current_user).first
    
    # if @sub != nil
    #   @sub.new_entries = 0
    #   @sub.last_entry_seen = @source.entries.last.id
    #   @sub.save
    # end
  end

  def new
    @source = Source.new
  end

  def edit
  end

  def create
    url = source_params["url"]

    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
    begin 
      doc = Nokogiri::HTML(open(url, 'proxy' => 'http://(ip_address):(port)', 'User-Agent' => user_agent, 'read_timeout' => '10' ), nil, "UTF-8")
    rescue
      resp = HTTParty.get(url)
      doc = Nokogiri::HTML(resp.body)
    end

    picture = doc.at('meta[property="og:image"]')['content']

    name = doc.at('meta[property="og:title"]')['content']

    rss_url = doc.at('link[type="application/rss+xml"]')['href']
    if rss_url == nil
      rss_url = doc.at('link[type="application/atom+xml"]')['href']
    end

    feed = Feedjira::Feed.fetch_and_parse rss_url

    # rss_url = source_params["rss_url"]
    # feed = Feedjira::Feed.fetch_and_parse rss_url
    # name = feed.title

    # if feed.url == nil
    #   url = feed.link
    # else
    #   url = feed.url
    # end

    # @picture = ""
    # if feed.try(:image) != nil
    #   if feed.image.try(:url) != nil
    #     @picture = feed.image.url
    #   end
    # end

    # if @picture == ""
    #   user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
    #   begin 
    #     doc = Nokogiri::HTML(open(url, 'proxy' => 'http://(ip_address):(port)', 'User-Agent' => user_agent, 'read_timeout' => '10' ), nil, "UTF-8")
    #     if doc.at('meta[property="og:image"]') != nil
    #       @picture = doc.at('meta[property="og:image"]')['content']
    #     end
    #   rescue
    #     resp = HTTParty.get(url)
    #     doc = Nokogiri::HTML(resp.body)
    #     @picture = doc.at('meta[property="og:image"]')['content']
    #   end
    # end

    @source = Source.new(name: name, url: url, rss_url: rss_url, picture: picture)

    respond_to do |format|
      if @source.save
        @source.refresh
        sub = Subscription.create(user_id: current_user.id, source_id: @source.id, new_entries: 0)
        sub.save
        format.html { redirect_to @source, notice: 'Source was successfully created.' }
        format.json { render :show, status: :created, location: @source }
      else
        if @source.errors.full_messages.first == "Url has already been taken"
          original_source = Source.find_by(url: @source.url)
          format.html { redirect_to source_path(original_source), notice: 'Source already existing. Redirecting to it.' }
        else
          format.html { render :new }
          format.json { render json: @source.errors, status: :unprocessable_entity }
        end
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
      params.require(:source).permit(:name, :url, :rss_url, :picture)
    end
end
