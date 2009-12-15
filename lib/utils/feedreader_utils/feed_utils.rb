require 'lib/utils/html_utils'
require 'lib/exceptions/invalid_feed_type_exception'
require 'rss/1.0'
require 'rss/2.0'

module FeedUtils
  #Number of milliseconds you should wait
  # until querying a feed again
  def self.QUERY_TIME
    #1/2 hour
    30 * 60
  end
  #Format for database time query
  def self.TIME_FORMAT
    "%Y-%m-%d %H:%M:%S"
  end
  #User agent for the HTTP requests
  def self.USER_AGENT
    'feedweedr/beta'
  end
  
  #Query the source to get new articles
  def self.query_source(feed)
    #Initialize article array
    articles = []
    #Query the xml_url
    url = URI.parse(feed.xml_url)
    req = Net::HTTP::Get.new(url.path)
    response = Net::HTTP.start(url.host, url.port) {|http|
      http.request_get(url.path, initheader = {'User-Agent' => self.USER_AGENT})
    }
    #Convert it to an REXML document if it is a successful response
    if response.kind_of? Net::HTTPSuccess
      article_xml = REXML::Document.new(response.body)
      #Set up an array to store the parsed articles in
      #TODO - It is possible that a feed will change types.
      # At this point, we remember that a feed is either
      # RSS or Atom, so if it changes types, we will
      # always try to parse the wrong type.  Need to
      # trap that situation.
      if feed.rss?
        articles = parse_rss(article_xml, feed)
      elsif feed.atom?
        articles = parse_atom(article_xml, feed)
      else
        articles = determine_type_and_parse(article_xml, feed)
      end
    end
    #See which ones need to be saved and save them.
    # For the ones that need saving, query full_text also.
    # Then set the query and updated time stamps.
    updated = false
    articles.each do |article|
      found_guid = false
      if article.pub_date.nil?
        #Can't use date to see if article exists, so check for guid
        unless article.guid.nil?
          #If the guid is nil, we have a problem, no way to tell if it's unique...
          found_guid = !Article.find(:all, :conditions => "feed_id = " + feed.id.to_s + " and guid = '" + article.guid + "'").empty?
        end
      end
      #If we haven't found it by guid, try date
      if !found_guid && (feed.last_updated.nil? || (article.pub_date <=> feed.last_updated) > 0)
        #Published after the last updated date
        # Get the full text, then save it
        article.full_text = query_full_text(article)
        article.save
        updated = true
      end
    end
    #Set the feeds timestamps
    feed.last_updated = Time.new if updated
    feed.last_queried = Time.new
    feed.save
  end
  
  def self.query_all_feeds
    now = Time.now
    threshold = now - self.QUERY_TIME
    feeds = Feed.find(:all, :conditions => "last_queried IS NULL OR last_queried < '" + threshold.strftime(self.TIME_FORMAT) + "'")
    feeds.each do |feed|
      begin
        #Query the source on each feed
        self.query_source(feed)
      rescue RuntimeError, Exception => e
        puts "#######Caught an exception in query_all_feeds (feed_utils.rb) - " + $! + "######"
      end
    end
  end
  
private
  #Parse XML from an RSS feed
  # Returns an array of Article objects
  def self.parse_rss(xml, feed)
    #Create an array of articles to return
    articles = []
    unless xml.nil?
      #Go through each item
      xml.elements.each("rss/channel/item") do |item|
        article = Article.new
        article.title = item.elements["title"].text if not item.elements["title"].nil?
        article.link = item.elements["link"].text if not item.elements["link"].nil?
        article.description = item.elements["description"].text if not item.elements["description"].nil?
        #Set the content to the description
        article.content = article.description
        article.guid = item.elements["guid"].text if not item.elements["guid"].nil?
        article.pub_date = Time.parse(item.elements["pubDate"].text) if not item.elements["pubDate"].nil?
        article.feed_id = feed.id
        articles << article
      end
    end
    return articles
  end
  #Parse XML from an Atom feed
  # Returns an array of Article objects
  def self.parse_atom(xml, feed)
    #Create an array of articles to return
    articles = []
    #Go through each entry
    unless xml.nil?
      xml.elements.each("feed/entry") do |entry|
        article = Article.new
        article.title = entry.elements["title"].text if not entry.elements["title"].nil?
        article.link = entry.elements["link"].attributes["href"]
        article.content = entry.elements["content"].text if not entry.elements["content"].nil?
        article.description = entry.elements["summary"].text if not entry.elements["summary"].nil?
        #Make sure both content and summary are filled in
        article.content = article.description if article.content.nil?
        article.description = article.content if article.description.nil?
        article.guid = entry.elements["id"].text if not entry.elements["id"].nil?
        article.pub_date = Time.parse(entry.elements["updated"].text) if not entry.elements["updated"].nil?
        #Some versions of atom use "modified" instead of "updated"
        article.pub_date = Time.parse(entry.elements["modified"].text) if article.pub_date.nil? && !entry.elements["modified"].nil?
        #Finally, some use the Dublin Core metadata elements
        article.pub_date = Time.parse(entry.elements["dc:date"].text) if article.pub_date.nil? && !entry.elements["dc:date"].nil?
        article.feed_id = feed.id
        #If the summary is nil, but the content is not, use content in both places
        article.description = article.full_text if article.description.nil?
        articles << article
      end
    end
    return articles
  end
  
  #Determine the type of feed, set it and save, then parse
  def self.determine_type_and_parse(xml, feed)
    if !xml.elements["feed/entry"].nil?
      #This is an atom feed
      feed.feed_type = Feed.ATOM
      feed.save
      self.parse_atom(xml, feed)
    elsif !xml.elements["rss/channel/item"].nil?
      #This is an RSS feed
      feed.feed_type = Feed.RSS
      feed.save
      self.parse_rss(xml, feed)
    else
      #Invalid type...
      raise InvalidFeedTypeException.new("Feed doesn't match Atom or RSS.")
    end
  end
  
  #Get the full text from an article
  def self.query_full_text(article)
    url = URI.parse(article.link)
    req = Net::HTTP::Get.new(url.path)
    response = Net::HTTP.start(url.host, url.port) {|http|
      http.request_get(url.path, initheader = {'User-Agent' => self.USER_AGENT})
    }
    #Convert it to an REXML document if it is a successful response
    if response.kind_of? Net::HTTPSuccess
      HTMLUtils.strip_html_tags(response.body)
    else
      ""
    end
  end
end