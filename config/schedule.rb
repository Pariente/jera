require 'rake'

every 2.minutes do
  rake "refresh", :environment => "development"
end
