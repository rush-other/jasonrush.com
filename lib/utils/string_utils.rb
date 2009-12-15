require 'lib/exceptions/invalid_data_type_exception'
require 'lib/exceptions/not_numeric_exception'

module StringUtils

  #Test for numericality
  def self.numeric?(input)
    #See if this is a kind of numeric
    if input.kind_of? Numeric
      return true
    elsif input.kind_of? String
      #This is a string
      # Convert to a number then back to a string
      # and see if the content changes
      if input.gsub(/,/, '').to_i.to_s == input.gsub(/,/, '') || 
        input.gsub(/,/, '').to_f.to_s == input.gsub(/,/, '')
        return true
      end
    end
    #No tests passed
    return false
  end
  
  #Sterilize user input before passing it on to a query
  # Datatype is either :string or :number
  def self.sterilize_user_input(input, datatype)
    if input.nil?
      nil
    elsif datatype == :string
      #If this should be a string, make sure that there are no
      # un-escaped quotes in the input.
      input = escape(input, "'")
      input = escape(input, '"')
      return input
    elsif datatype == :number
      #If there is non-numeric input, raise an exception
      if numeric?(input)
        return input.to_s
      end
      #Raise an exception - not numeric
      if input.nil?
        str = "nil"
      else
        str = input.to_s
      end
      raise NotNumericException.new("Input is not numeric: " + str)
    else
      #Raise an exception, not string or number (nothing else supported at this point)
      #TODO - Include data sterilization
      raise InvalidDataTypeException.new("Invalid data type on sterilize: " + datatype.to_s)
    end
  end
  
  #Add an escape character (\) before a particular character
  def self.escape(str, char)
    replacement = "\\\\" + char
    return str if str.nil? || str.index(char).nil?
    return str.gsub(char, replacement)
  end
end