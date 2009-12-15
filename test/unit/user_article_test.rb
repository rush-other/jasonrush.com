require File.dirname(__FILE__) + '/../test_helper'

class UserArticleTest < Test::Unit::TestCase
  fixtures :user_articles

  #Test validations
  def test_valid_save
    article = UserArticle.new
    article.article_id = 1
    article.user_id = 1
    article.unread = false
    article.rating = 3
    assert article.save
  end
  def test_no_article_id
    article = UserArticle.new
    article.user_id = 1
    article.unread = 0
    article.rating = 3
    assert !article.save
    assert_error_message(article, {"article_id", "can't be blank"})
  end
  def test_no_user_id
    article = UserArticle.new
    article.article_id = 1
    article.unread = 0
    article.rating = 3
    assert !article.save
    assert_error_message(article, {"user_id", "can't be blank"})
  end
  def test_no_rating
    article = UserArticle.new
    article.article_id = 1
    article.user_id = 1
    article.unread = 0
    article.rating = nil  #Has to be explicitly nil'd because it has a default
    assert !article.save
    assert_error_message(article, {"rating", "can't be blank"})
  end
  def test_article_user_not_unique
    article = UserArticle.new
    article.article_id = 2
    article.user_id = 1
    article.unread = 0
    article.rating = 3
    assert !article.save
    assert_error_message(article, {"article_id", "has already been taken"})
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
