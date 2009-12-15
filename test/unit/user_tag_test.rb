require File.dirname(__FILE__) + '/../test_helper'

class UserTagTest < Test::Unit::TestCase
  fixtures :user_tags

  #Test validations
  def test_valid_save
    tag = UserTag.new
    tag.tag_id = 1
    tag.article_id = 1
    tag.user_id = 1
    assert tag.save
  end
  def test_no_tag_id
    tag = UserTag.new
    tag.article_id = 1
    tag.user_id = 1
    assert !tag.save
    assert_error_message(tag, {"tag_id", "can't be blank"})
  end
  def test_no_article_id
    tag = UserTag.new
    tag.tag_id = 1
    tag.user_id = 1
    assert !tag.save
    assert_error_message(tag, {"article_id", "can't be blank"})
  end
  def test_no_user_id
    tag = UserTag.new
    tag.article_id = 1
    tag.tag_id = 1
    assert !tag.save
    assert_error_message(tag, {"user_id", "can't be blank"})
  end
  def test_tag_not_unique
    tag = UserTag.new
    tag.tag_id = 2
    tag.article_id = 1
    tag.user_id = 1
    assert !tag.save
    assert_error_message(tag, {"tag_id", "has already been taken"})
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
