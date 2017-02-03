desc "Refreshing sources entries every 20 minutes"

task :refresh => :environment do
  sources = Source.all
  sources.each do |s|
    s.refresh
  end
end