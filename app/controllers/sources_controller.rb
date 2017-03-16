class SourcesController < ApplicationController
  before_action :set_source, only: [:show, :edit, :update]
  before_action :set_last_action_at
  require 'open-uri'

  def top
    @top = Source.all.sort_by {|s| s.subscriptions_count}.reverse.first(50)
    @search = ransack_params
  end

  def latest
    @latest = Source.last(50).reverse
    @search = ransack_params
  end

  def results
    @search = ransack_params
    @results  = ransack_result
    @source = Source.new
  end

  def show_latest
    @referer = params[:referer]
    @latest = []
    @new = []
    @source = Source.find(params[:id])
    last_entries = @source.last_entries(50).reverse

    last_entries.each do |e|
      unless e.is_masked_by_user?(current_user) || e.is_picked_by_user?(current_user)
        if e.is_new?(current_user)
          @new.push(e)
        else
          @latest.push(e)
        end
      end
    end
    
    # MARKING THE SUBSCRIPTION AS CHECKED
    @sub = @source.subscriptions.where(user: current_user).first
    unless @sub == nil
      @sub.last_time_checked = Time.now
      @sub.new_entries = 0
      @sub.save
    end
  end

  def show_harvested
    @referer = params[:referer]
    @unread = []
    @harvest = []
    @source = Source.find(params[:id])

    pickings = current_user.pickings.where(source_id: @source.id)
    pickings = pickings.sort_by {|p| p.created_at}.reverse

    pickings.each do |p|
      if p.entry.is_read_by_user?(current_user)
        @harvest.push(p.entry)
      else
        @unread.push(p.entry)
      end
    end
    
    # MARKING THE SUBSCRIPTION AS CHECKED
    @sub = @source.subscriptions.where(user: current_user).first
    unless @sub == nil
      @sub.last_time_checked = Time.now
      @sub.new_entries = 0
      @sub.save
    end
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

    # feed = Feedjira::Feed.fetch_and_parse rss_url
    @source = Source.new(name: name, url: url, rss_url: rss_url, picture: picture)

    respond_to do |format|
      if rss_url != nil && @source.save
        @source.refresh
        sub = Subscription.create(user_id: current_user.id, source_id: @source.id, last_time_checked: 1.week.ago, new_entries: 0)
        sub.save
        format.html { redirect_to source_show_latest_path(@source), notice: 'Source was successfully created.' }
        format.json { render :show_latest, status: :created, location: @source }
      else
        if @source.errors.full_messages.first == "Url has already been taken"
          original_source = Source.find_by(url: @source.url)
          format.html { redirect_to source_show_latest_path(original_source), notice: 'Source already existing. Redirecting to it.' }
        else
          format.html { redirect_to unable_to_fetch_path }
          format.json { render json: @source.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def unable_to_fetch
    @search = ransack_params
  end

  def update
    respond_to do |format|
      if @source.update(source_params)
        format.html { redirect_to @source, notice: 'Source was successfully updated.' }
        format.json { render :show_latest, status: :ok, location: @source }
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
