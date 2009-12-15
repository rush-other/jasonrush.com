require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users, :folders, :user_feeds
  
  #Test active-only collections
  def test_active_folders
    user = User.find(2)
    active_folders = user.folders #Only active ones
    assert active_folders.size == 1
    assert active_folders.first.id == 2
  end
  def test_active_user_feeds
    user = User.find(2)
    active_feeds = user.user_feeds #Only active ones
    assert active_feeds.size == 1
    assert active_feeds.first.id == 2
  end
  #Test inactivation
  def test_inactivation
    user = User.find(1)
    assert user.active
    user.inactivate
    user.save
    assert !user.active
  end
  #Test encryption
  def test_encryption
    pwd = "password"
    encrypted = User.encrypt_password(pwd)
    assert encrypted == "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8"
  end
  #Test validations
  def test_valid_save
    user = User.new
    user.username = "user"
    user.password = "password"
    user.first_name = "First"
    user.last_name = "Last"
    user.email = "user@user.com"
    user.active = true
    assert user.save
  end
  def test_no_username
    user = User.new
    user.password = "password"
    user.first_name = "First"
    user.last_name = "Last"
    user.email = "user@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"username", "can't be blank"})
  end
  def test_no_password
    user = User.new
    user.username = "user"
    user.first_name = "First"
    user.last_name = "Last"
    user.email = "user@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"password", "can't be blank"})
  end
  def test_no_first_name
    user = User.new
    user.username = "user"
    user.password = "password"
    user.last_name = "Last"
    user.email = "user@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"first_name", "can't be blank"})
  end
  def test_no_last_name
    user = User.new
    user.username = "user"
    user.password = "password"
    user.first_name = "First"
    user.email = "user@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"last_name", "can't be blank"})
  end
  def test_no_email
    user = User.new
    user.username = "user"
    user.password = "password"
    user.first_name = "First"
    user.last_name = "Last"
    user.active = true
    assert !user.save
    assert_error_message(user, {"email", "can't be blank"})
  end
  def test_username_too_long
    user = User.new
    user.username = too_long_text(20)
    user.password = "password"
    user.first_name = "First"
    user.last_name = "Last"
    user.email = "user@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"username" => "is too long (maximum is 20 characters)"})
  end
  def test_password_too_long
    user = User.new
    user.username = "user"
    user.password = too_long_text(50)
    user.first_name = "First"
    user.last_name = "Last"
    user.email = "user@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"password" => "is too long (maximum is 50 characters)"})
  end
  def test_first_name_too_long
    user = User.new
    user.username = "user"
    user.password = "password"
    user.first_name = too_long_text(50)
    user.last_name = "Last"
    user.email = "user@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"first_name" => "is too long (maximum is 50 characters)"})
  end
  def test_last_name_too_long
    user = User.new
    user.username = "user"
    user.password = "password"
    user.first_name = "First"
    user.last_name = too_long_text(50)
    user.email = "user@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"last_name" => "is too long (maximum is 50 characters)"})
  end
  def test_email_too_long
    user = User.new
    user.username = "user"
    user.password = "password"
    user.first_name = "First"
    user.last_name = "Last"
    user.email = too_long_text(255)
    user.active = true
    assert !user.save
    assert_error_message(user, {"email" => "is too long (maximum is 255 characters)"})
  end
  
  def test_username_not_unique
    user = User.new
    user.username = "unique"
    user.password = "password"
    user.first_name = "First"
    user.last_name = "Last"
    user.email = "unique@user.com"
    user.active = true
    assert !user.save
    assert_error_message(user, {"username", "has already been taken"})
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
