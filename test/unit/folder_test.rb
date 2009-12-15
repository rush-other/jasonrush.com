require File.dirname(__FILE__) + '/../test_helper'

class FolderTest < Test::Unit::TestCase
  fixtures :folders
  fixtures :user_feeds

  #Test inactive feeds
  def test_active_user_feeds
    folder = Folder.find(2)
    active_feeds = folder.user_feeds #Only active ones
    assert active_feeds.size == 1
    assert active_feeds.first.id == 2
  end
  #Test inactivation
  def test_inactivation
    folder = Folder.find(2)
    puts ""
    folder.inactivate
    folder_redux = Folder.find(2)
    #Make sure that inactivated it
    assert !folder_redux.active
    #Now make sure that the feed relationship was nullified
    feed = UserFeed.find(2)
    assert feed.folder_id.nil?
  end
  
  #Test validations
  def test_valid_save
    folder = Folder.new
    folder.title = "my folder"
    folder.active = 1
    folder.user_id = 1
    assert folder.save
  end
  def test_no_title
    folder = Folder.new
    folder.active = 1
    folder.user_id = 1
    assert !folder.save
    assert_error_message(folder, {"title", "can't be blank"})
  end
  def test_no_user
    folder = Folder.new
    folder.active = 1
    folder.title = "my folder"
    assert !folder.save
    assert_error_message(folder, {"user_id", "can't be blank"})
  end
  def test_title_too_long
    folder = Folder.new
    folder.title = too_long_text(50)
    folder.active = 1
    folder.user_id = 1
    assert !folder.save
    assert_error_message(folder, {"title" => "is too long (maximum is 50 characters)"})
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
