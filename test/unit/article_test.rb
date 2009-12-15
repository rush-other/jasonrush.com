require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :articles, :feeds

  #Test validations
  def test_valid_save
    article = Article.new
    article.title = "test"
    article.link = "http://test.com/feed.xml?id=1"
    article.description = "blah blah blah"
    article.guid = "1234567890"
    article.pub_date = Date.today
    article.feed_id = 1
    assert article.save
  end
  def test_no_feed_id
    article = Article.new
    article.title = "test"
    article.link = "http://test.com/feed.xml?id=1"
    article.description = "blah blah blah"
    article.guid = "1234567890"
    article.pub_date = Date.today
    assert !article.save
    assert_error_message(article, {"feed_id" => "can't be blank"})
  end
  def test_title_too_long
    article = Article.new
    article.title = too_long_text(255)
    article.link = "http://test.com/feed.xml?id=1"
    article.description = "blah blah blah"
    article.guid = "1234567890"
    article.pub_date = Date.today
    article.feed_id = 1
    assert !article.save
    assert_error_message(article, {"title" => "is too long (maximum is 255 characters)"})
  end
  def test_link_too_long
    article = Article.new
    article.title = "test"
    article.link = too_long_text(255)
    article.description = "blah blah blah"
    article.guid = "1234567890"
    article.pub_date = Date.today
    article.feed_id = 1
    assert !article.save
    assert_error_message(article, {"link" => "is too long (maximum is 255 characters)"})
  end
  def test_guid_too_long
    article = Article.new
    article.title = "test"
    article.link = "http://test.com/feed.xml?id=1"
    article.description = "blah blah blah"
    article.guid = too_long_text(255)
    article.pub_date = Date.today
    article.feed_id = 1
    assert !article.save
    assert_error_message(article, {"guid" => "is too long (maximum is 255 characters)"})
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
