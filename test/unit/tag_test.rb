require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :tags

  #Test validations
  def test_valid_save
    tag = Tag.new
    tag.tag = "test"
    assert tag.save
  end
  def test_no_tag
    tag = Tag.new
    assert !tag.save
    assert_error_message(tag, {"tag", "can't be blank"})
  end
  def test_tag_too_long
    tag = Tag.new
    tag.tag= too_long_text(50)
    assert !tag.save
    assert_error_message(tag, {"tag" => "is too long (maximum is 50 characters)"})
  end
  def test_tag_not_unique
    tag = Tag.new
    tag.tag = "unique"
    assert !tag.save
    assert_error_message(tag, {"tag", "has already been taken"})
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
