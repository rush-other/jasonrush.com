require File.dirname(__FILE__) + '/../test_helper'

class ActsAsInactivatableTest < Test::Unit::TestCase
  fixtures :users
  
  def test_find_active_no_condition
    users = User.find_active
    assert users.length == 2
  end
  def test_find_active_string_condition
    users = User.find_active(:conditions => "email = 'email@email.com'")
    assert users.length == 2
  end
  def test_find_active_array_condition
    users = User.find_active(:conditions => ["email = ?", "email@email.com"])
    assert users.length == 2
  end
end