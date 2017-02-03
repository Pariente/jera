require 'open-uri'
url = "https://www.reddit.com/r/MapPorn/comments/5rjbmg/map_of_americas_50_largest_metropolitan_areas_by/"
user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
doc = Nokogiri::HTML(open(url, 'proxy' => 'http://(ip_address):(port)', 'User-Agent' => user_agent, 'read_timeout' => '10' ), nil, "UTF-8")
html = open(url, "User-Agent" => "Ruby", 'read_timeout' => '10' ).read
