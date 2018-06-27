class SourcesController < ApplicationController
  require 'open-uri'
  require 'csv'
  include ApplicationHelper

  def index
    @source = Source.new
    @search = ransack_params
    if params[:filter] == 'popular'
      @sources = Source.all.sort_by {|s| s.subscriptions_count}.last(30).reverse
    else
      @sources = Source.last(30).reverse
    end
  end

  def edit
    @source = Source.find(params[:id])
  end

  def results
    @search = ransack_params
    @sources = ransack_result
    @source = Source.new
    respond_to do |format|
      format.html { render 'index.html.erb' }
    end
  end

  def show
    @filter = params[:filter]
    @search = ransack_params
    @source = Source.find(params[:id])
    @entries = []

    if @filter == 'harvested'
      @entries = Entry.joins(:entry_actions).where(entry_actions: {user_id: current_user.id, source_id: @source.id, harvested: true}).reverse_order.limit(20).to_a
    else
      @entries = @source.last_entries(30).sort_by {|p| p.created_at}.reverse
    end
  end

  def new
    @search = ransack_params
    @source = Source.new
  end

  def create
    url = source_params[:url]

    if uri?(url)

      # FETCHING URL BODY
      user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
      begin 
        doc = Nokogiri::HTML(open(url, 'proxy' => 'http://(ip_address):(port)', 'User-Agent' => user_agent, 'read_timeout' => '10' ), nil, "UTF-8")
      rescue
        resp = HTTParty.get(url)
        doc = Nokogiri::HTML(resp.body)
      end

      # FETCHING PICTURE
      if source_params[:picture] == nil
        og_image = doc.at('meta[property="og:image"]')
        picture = ""
        unless og_image == nil
          picture = og_image['content']
        end
      else
        picture = source_params[:picture]
      end

      # FETCHING NAME
      if source_params[:name] == nil
        og_title = doc.at('meta[property="og:title"]')
        if og_title == nil
          name = doc.at('title').text
        else
          name = og_title['content']
        end
      else
        name = source_params[:name]
      end

      # FETCHING RSS URL
      if source_params[:rss_url] == nil
        rss_xml = doc.at('link[type="application/rss+xml"]')
        if rss_xml == nil
          rss_xml = doc.at('link[type="application/atom+xml"]')
        end 
        unless rss_xml == nil
          rss_url = rss_xml['href']
        end
      else
        rss_url = source_params[:rss_url]
      end

      # INSTANTIATING SOURCE
      @source = Source.new(name: name, url: url, rss_url: rss_url, picture: picture)

      respond_to do |format|
        if rss_url != nil && @source.save
          @source.refresh
          sub = Subscription.create(user_id: current_user.id, source_id: @source.id)
          sub.save
          format.html { redirect_to source_show_path(@source), notice: 'Source was successfully created.' }
          format.json { render :show_latest, status: :created, location: @source }
        else
          if @source.errors.full_messages.first == "Url has already been taken"
            original_source = Source.find_by(url: @source.url)
            format.html { redirect_to source_show_path(original_source), notice: 'Source already existing. Redirecting to it.' }
          else
            format.html { redirect_to source_new_path }
            format.json { render json: @source.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to source_new_path }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @source = Source.find(params[:id])
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
    def ransack_params
      Source.ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct: true)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_params
      params.require(:source).permit(:name, :url, :rss_url, :picture)
    end
end
