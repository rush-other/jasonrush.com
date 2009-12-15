require "rexml/document"

class UserFeed < ActiveRecord::Base
  #Relationships
  belongs_to :feed
  belongs_to :folder
  belongs_to :user
  
  #Validations
  validates_presence_of :feed_id
  validates_presence_of :title
  validates_presence_of :user_id
  validates_length_of :title, :maximum => 255
  
  #Extensions
  acts_as_inactivatable
  
end
