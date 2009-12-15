require File.dirname(__FILE__) + '/../test_helper'
require 'lib/utils/string_utils'
require 'lib/utils/html_utils'

class UtilsTest < Test::Unit::TestCase
  #Test String Utils
  def test_numeric
    assert StringUtils.numeric?("123")
    assert StringUtils.numeric?("123.45")
    assert StringUtils.numeric?(123)
    assert StringUtils.numeric?(123.45)
    assert StringUtils.numeric?("1,234")
    assert StringUtils.numeric?("1,234.56")
    assert !StringUtils.numeric?("abc")
    assert !StringUtils.numeric?("123abc")
    assert !StringUtils.numeric?("123.45.67")
  end
  
  def test_sterilize_user_input_valid_string
    input = StringUtils.sterilize_user_input("hello", :string)
    assert input == "hello"
  end
  
  def test_sterilize_user_input_invalid_string
    input = StringUtils.sterilize_user_input("'hello'", :string)
    assert input == "\\\'hello\\\'"
  end
  
  def test_sterilize_user_input_valid_number_string
    input = StringUtils.sterilize_user_input("123", :number)
    assert input == "123"
  end
  
  def test_sterilize_user_input_valid_number
    input = StringUtils.sterilize_user_input(123, :number)
    assert input == "123"
  end
  
  def test_sterilize_user_input_invalid_number
    assert_raise(NotNumericException) {StringUtils.sterilize_user_input("abc", :number)}
  end
  
  def test_sterilize_user_input_invalid_datatype
    assert_raise(InvalidDataTypeException) {StringUtils.sterilize_user_input(123, :invalid)}
  end
  
  def test_escape
    input = "'hello'"
    input = StringUtils.escape(input, "'")
    assert input == "\\\'hello\\\'"
  end
  
  #Test HTML Utils
  def test_strip_html_tags
    html = "<html><head><title>Hello World</title></head><body><p class='cssclass'>Hello Again</p></body></html>"
    assert HTMLUtils.strip_html_tags(html) == "Hello World Hello Again"
  end
end