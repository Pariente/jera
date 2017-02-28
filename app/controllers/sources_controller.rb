class SourcesController < ApplicationController
  before_action :set_source, only: [:show, :edit, :update]
  before_action :set_last_action_at
  require 'open-uri'

  def top
    sources = Source.all
    @top = sources.sort_by {|source| source.subscriptions.count}.reverse
    @top = @top.first(100)
    @search = ransack_params
  end

  def latest
    sources = Source.all
    @latest = sources.sort_by {|source| source.created_at}.reverse
    @latest = @latest.first(100)
    @search = ransack_params
  end

  def results
    @search = ransack_params
    @results  = ransack_result
    @source = Source.new
  end

  def show
    @harvest = []
    @new = []

    @source.last_entries(50).each do |e|
      unless e.is_masked_by_user?(current_user)
        if e.is_new?(current_user)
          @new.push(e)
        else
          @harvest.push(e)
        end
      end
    end

    # SORTING HARVEST BY REVERSE CHRONOLOGICAL ORDER
    @harvest = @harvest.sort_by {|entry| entry.created_at}.reverse
    @new = @new.sort_by {|entry| entry.created_at}.reverse
    
    @sub = @source.subscriptions.where(user: current_user).first
    @sub.last_time_checked = Time.now
    @sub.new_entries = 0
    @sub.save
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

    og_image = doc.at('meta[property="og:image"]')
    picture = ""
    unless og_image == nil
      picture = og_image['content']
    end

    og_title = doc.at('meta[property="og:title"]')
    if og_title == nil
      name = doc.at('title').text
    else
      name = og_title['content']
    end

    rss_xml = doc.at('link[type="application/rss+xml"]')
    if rss_xml == nil
      rss_xml = doc.at('link[type="application/atom+xml"]')
    end 
    unless rss_xml == nil
      rss_url = rss_xml['href']
    end

    feed = Feedjira::Feed.fetch_and_parse rss_url

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

  private
    def set_last_action_at
      if Time.now > (current_user.last_session_last_action + 30*60)
        current_user.previous_session_last_action = current_user.last_session_last_action
      end
      current_user.last_session_last_action = Time.now
      current_user.save
    end

    def ransack_params
      Source.ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct: true)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_source
      @source = Source.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_params
      params.require(:source).permit(:name, :url, :rss_url, :picture)
    end
end
