require File.dirname(__FILE__) + '/../test_helper'

class UserFeedTest < Test::Unit::TestCase
  fixtures :user_feeds

  #Test inactivation
  def test_inactivation
    feed = UserFeed.find(1)
    assert feed.active
    feed.inactivate
    feed.save
    assert !feed.active
  end
  
  #Test validations
  def test_valid_save
    feed = UserFeed.new
    feed.feed_id = 1
    feed.title = "my feed"
    feed.description = "blah blah blah"
    feed.user_id = 1
    feed.active = 1
    assert feed.save
  end
  def test_no_feed_id
    feed = UserFeed.new
    feed.title = "my feed"
    feed.description = "blah blah blah"
    feed.user_id = 1
    feed.active = 1
    assert !feed.save
    assert_error_message(feed, {"feed_id", "can't be blank"})
  end
  def test_no_title
    feed = UserFeed.new
    feed.feed_id = 1
    feed.description = "blah blah blah"
    feed.user_id = 1
    feed.active = 1
    assert !feed.save
    assert_error_message(feed, {"title", "can't be blank"})
  end
  def test_no_user_id
    feed = UserFeed.new
    feed.feed_id = 1
    feed.title = "my feed"
    feed.description = "blah blah blah"
    feed.active = 1
    assert !feed.save
    assert_error_message(feed, {"user_id", "can't be blank"})
  end
  def test_title_too_long
    feed = UserFeed.new
    feed.feed_id = 1
    feed.title = too_long_text(100)
    feed.description = "blah blah blah"
    feed.user_id = 1
    feed.active = 1
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
