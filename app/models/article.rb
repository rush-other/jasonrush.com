class Article < ActiveRecord::Base
  #Relationships
  belongs_to :feed
  
  #Validations
  validates_presence_of :feed_id
  validates_length_of :title, :maximum => 255
  validates_length_of :link, :maximum => 255
  validates_length_of :guid, :maximum => 255
  
end
