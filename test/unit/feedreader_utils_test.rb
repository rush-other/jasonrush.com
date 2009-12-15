require File.dirname(__FILE__) + '/../test_helper'
require 'lib/utils/feedreader_utils/opml_utils'
require 'lib/utils/feedreader_utils/feed_utils'

class FeedReaderUtilsTest < Test::Unit::TestCase
  fixtures :feeds
  
  #Test the import of an OPML file
  def test_import_opml
    require "rexml/document"
    file = File.new("C:\\devel\\ruby\\feed_weeder\\test\\opml_export_example")
    doc = REXML::Document.new file
    OPMLUtils.import_opml(doc, 1)
    #Make sure all folders are there
    folders = Folder.find(:all, :conditions => "active = 1 and user_id = 1")
    assert folders.size == 6
    #Note that this tests that no duplicates are imported
    # and that no nested folders were imported (just the lowest level)
    
    #Test that all expected folders were found
    devel = false
    funny = false
    news = false
    personal = false
    second_life = false
    tech = false
    news_folder_id = nil
    folders.each do |folder|
      devel = true if folder.title == 'devel'
      funny = true if folder.title == 'funny'
      if folder.title == 'news'
        news = true
        news_folder_id = folder.id #Will use this to test expected feeds in a sec
      end
      personal = true if folder.title == 'personal'
      second_life = true if folder.title == 'second-life'
      tech = true if folder.title == 'tech'
    end
    assert devel && funny && news && personal && second_life && tech
    #Now, in one folder (devel), test that all feeds that we expect are there
    feeds = UserFeed.find(:all, :conditions => "folder_id = " + news_folder_id.to_s + " and user_id = 1")
    assert feeds.size == 3
    americablog = false
    cnn = false
    nyt = false
    feeds.each do |feed|
      americablog = true if feed.title == "AMERICAblog: A great nation deserves the truth"
      cnn = true if feed.title == "CNN.com"
      nyt = true if feed.title == "NYT > Home Page"
      #Make sure feed relationship is set up correctly
      assert !feed.feed.nil?
      assert !feed.feed.id.nil?
    end
    assert americablog && cnn && nyt
    #Now test for duplicates (fixtures should have been overriden)
    #First for feeds:
    americablog_feeds = Feed.find(:all, :conditions => "xml_url = 'http://feeds.feedburner.com/Americablog'")
    assert americablog_feeds.size == 1
    assert americablog_feeds.first.title == "AMERICAblog: A great nation deserves the truth"
    #Now with user feeds
    americablog_userfeeds = UserFeed.find(:all, :conditions => "user_id = 1 and feed_id = " + americablog_feeds.first.id.to_s)
    assert americablog_userfeeds.size == 1
    #Don't need to recheck the title override, because this is what we found during the 
    # feed check above.
  end

  #Test Article Query
  def test_query_all
    #Query all feeds
    FeedUtils.query_all_feeds
    #Now make sure there are articles for each feed
    feeds = Feed.find(:all)
    feeds.each do |feed|
      if feed.articles.empty?
        puts feed.html_url
      end
      assert !feed.articles.nil?
      assert !feed.articles.empty?
    end
  end
end