class Source < ActiveRecord::Base
  has_many :subscriptions
  has_many :entries
  validates :url, uniqueness: true

  def refresh

    # FETCHING FEED
    feed = Feedjira::Feed.fetch_and_parse self.rss_url

    feed.entries.each do |e|

      # CHECKING IF ENTRIES ARE IN THE DATABASE
      if (Entry.where(media_url: e.url) == [])

        # RETRIEVING ENTRY THUMBNAIL
        image = ""
        if e.try(:media_thumbnail_url) != nil
          image = e.media_thumbnail_url
        elsif e.try(:image) != nil
          image = e.image
        else
          user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
          doc = Nokogiri::HTML(open(e.url, 'User-Agent' => user_agent, 'read_timeout' => '1' ), nil, "UTF-8")
          unless doc.at('meta[property="og:image"]') == nil
            image = doc.at('meta[property="og:image"]')['content']
          end
        end

        # RETRIEVING ENTRY DESCRIPTION
        content = ""
        if e.try(:content) != nil
          content = e.content
        elsif e.try(:description) != nil
          content = e.description
        elsif e.try(:summary) != nil
          content = e.summary
        end

        content = ActionController::Base.helpers.strip_tags(content)
        content = CGI::unescapeHTML(content)

        # ADDING ENTRY TO THE DATABASE
        Entry.create(
          source_id: self.id, 
          title: e.title,
          content: content,
          published_date: e.published, 
          media_url: e.url,
          thumbnail_url: image)
      end
    end
  end

  def in_garden_of_user(current_user)
    s = Subscription.where(source_id: self.id, user_id: current_user.id)
    if s == []
      return nil
    else
      return s.first
    end
  end

  def entries_since(date)
    Entry.where("source_id = ? AND published_date > ?", self.id, date)
  end

  def last_entries(number)
    Entry.where(source_id: self.id).last(number)
  end

end
