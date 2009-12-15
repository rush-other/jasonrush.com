require File.dirname(__FILE__) + '/../test_helper'

class FeedTest < Test::Unit::TestCase
  fixtures :feeds

  #Test validations
  def test_valid_save
    feed = Feed.new
    feed.xml_url = "http://test.com/feed.xml"
    feed.html_url = "http://test.com/"
    feed.feed_type = 0
    feed.title = "test feed"
    feed.description = "blah blah blah"
    feed.last_updated = Date.today
    feed.last_queried = Date.today
    assert feed.save
  end
  def test_no_xml_url
    feed = Feed.new
    feed.html_url = "http://test.com/"
    feed.feed_type = 0
    feed.title = "test feed"
    feed.description = "blah blah blah"
    feed.last_updated = Date.today
    feed.last_queried = Date.today
    assert !feed.save
    assert_error_message(feed, {"xml_url", "can't be blank"})
  end
  def test_xml_url_not_unique
    feed = Feed.new
    feed.xml_url = "http://feeds.feedburner.com/Americablog"
    feed.html_url = "http://www.americablog.com/"
    feed.feed_type = 0
    feed.title = "test feed"
    feed.description = "blah blah blah"
    feed.last_updated = Date.today
    feed.last_queried = Date.today
    assert !feed.save
    assert_error_message(feed, {"xml_url", "has already been taken"})
  end
  def test_no_html_url
    feed = Feed.new
    feed.xml_url = "http://test.com/feed.xml"
    feed.feed_type = 0
    feed.title = "test feed"
    feed.description = "blah blah blah"
    feed.last_updated = Date.today
    feed.last_queried = Date.today
    assert !feed.save
    assert_error_message(feed, {"html_url", "can't be blank"})
  end
  def test_invalid_feed_type
    feed = Feed.new
    feed.xml_url = "http://test.com/feed.xml"
    feed.html_url = "http://test.com/"
    feed.feed_type = 3
    feed.title = "test feed"
    feed.description = "blah blah blah"
    feed.last_updated = Date.today
    feed.last_queried = Date.today
    assert !feed.save
    assert_error_message(feed, {"feed_type" => "is not a valid type of feed"})
  end
  def test_xml_url_too_long
    feed = Feed.new
    feed.xml_url = too_long_text(255)
    feed.html_url = "http://test.com/"
    feed.feed_type = 0
    feed.title = "test feed"
    feed.description = "blah blah blah"
    feed.last_updated = Date.today
    feed.last_queried = Date.today
    assert !feed.save
    assert_error_message(feed, {"xml_url" => "is too long (maximum is 255 characters)"})
  end
  def test_html_url_too_long
    feed = Feed.new
    feed.xml_url = "http://test.com/feed.xml"
    feed.html_url = too_long_text(255)
    feed.feed_type = 0
    feed.title = "test feed"
    feed.description = "blah blah blah"
    feed.last_updated = Date.today
    feed.last_queried = Date.today
    assert !feed.save
    assert_error_message(feed, {"html_url" => "is too long (maximum is 255 characters)"})
  end
  def test_title_too_long
    feed = Feed.new
    feed.xml_url = "http://test.com/feed.xml"
    feed.html_url = "http://test.com/"
    feed.feed_type = 0
    feed.title = too_long_text(100)
    feed.description = "blah blah blah"
    feed.last_updated = Date.today
    feed.last_queried = Date.today
    assert !feed.save
    assert_error_message(feed, {"title" => "is too long (maximum is 100 characters)"})
  end
  
private
  def too_long_text(len)
    #Return a string longer than len chars
    str = ""
    (len+1).times do
      str += "a"
    end
    str
  end
  
  def assert_error_message(record, errors)
    errors.each do |prop, msg|
      found = false
      #Make sure the appropriate error message is included
      assert !record.errors[prop].nil?
      record.errors[prop].each do |err|
        found = true if err == msg
      end
      assert found
    end
  end
end
