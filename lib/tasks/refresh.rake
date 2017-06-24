desc "Refreshing sources entries every 20 minutes"

task :refresh => :environment do
  sources = Source.all
  sources.each do |s|
    begin
      s.refresh
    rescue Exception => e
      puts "Error #{e}"
      next   # <= This is what you were looking for
    end
  end
end