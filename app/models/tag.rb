class Tag < ActiveRecord::Base
  #Validations
  validates_presence_of :tag
  validates_length_of :tag, :maximum => 50
  validates_uniqueness_of :tag
end
