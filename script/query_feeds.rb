require 'rubygems'
require 'active_record'
require 'app/models/feed'
require 'app/models/article'
require 'lib/utils/feedreader_utils/feed_utils'

#This script runs continuously in the background to update the articles
# in the database for all feeds.

ActiveRecord::Base.establish_connection(  
   :adapter  => 'mysql',   
   :database => 'feed_weedr_development',   
   :username => 'feed_weeder',   
   :password => 'iop90jkl',   
   :host     => 'localhost'
) 

#Loop continuously and check for feeds every 5 minutes
while true do
  #Now query all feeds that haven't been queried
  # in the last Feed.QUERY_TIME period
  begin
    puts "Querying all feeds..."
    FeedUtils.query_all_feeds
    puts "Finished querying all feeds..."
  rescue
    puts "#######Caught an exception in main loop (environment.rb) - " + $! + "######"
  end
  #Sleep for 5 minutes
  sleep 300
end
