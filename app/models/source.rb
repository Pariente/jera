class Source < ActiveRecord::Base
  has_many :subscriptions
  has_many :entries
  has_many :entry_actions
  validates :url, uniqueness: true

  def self.to_csv
    attributes = %w{name url rss_url picture}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def refresh

    # FETCHING FEED
    feed = Feedjira::Feed.fetch_and_parse self.rss_url.to_s

    feed.entries.each do |e|

      # CHECKING IF ENTRIES ARE IN THE DATABASE
      if (Entry.where(media_url: e.url.to_s) == [])

        p 'inside where entry media url'
        # RETRIEVING ENTRY THUMBNAIL
        image = ""
        if e.try(:media_thumbnail_url) != nil
          image = e.media_thumbnail_url.to_s
        elsif e.try(:image) != nil
          image = e.image.to_s
        else
          p 'inside else'
          user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
          doc = Nokogiri::HTML(open(e.url.to_s, 'User-Agent' => user_agent, 'read_timeout' => '1' ), nil, "UTF-8")
          p 'after doc nokogiri'
          unless doc.at('meta[property="og:image"]') == nil
            p 'inside unless'
            image = doc.at('meta[property="og:image"]')['content'].to_s
          end
        end
        p 'after image retrieving'

        # RETRIEVING ENTRY DESCRIPTION
        content = ""
        if e.try(:content) != nil
          content = e.content.to_s
        elsif e.try(:description) != nil
          content = e.description.to_s
        elsif e.try(:summary) != nil
          content = e.summary.to_s
        end

        p 'after content retrieving'

        content = ActionController::Base.helpers.strip_tags(content)
        content = CGI::unescapeHTML(content)
        content = content.truncate(300)

        p 'after content formating'

        # ADDING ENTRY TO THE DATABASE
        Entry.create(
          source_id: self.id, 
          title: e.title,
          content: content,
          published_date: e.published, 
          media_url: e.url.to_s,
          thumbnail_url: image)

        p 'after entry creating'
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

  def subscriptions_count
    self.subscriptions.count
  end

end
