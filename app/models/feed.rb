require 'net/http'
require 'rexml/document'
require 'lib/utils/feedreader_utils/feed_utils'

class Feed < ActiveRecord::Base
  #Relationships
  has_many :articles
  
  #Validations
  validates_presence_of :xml_url
  validates_presence_of :html_url
  validates_length_of :xml_url, :maximum => 255
  validates_length_of :html_url, :maximum => 255
  validates_length_of :title, :maximum => 255
  validates_uniqueness_of :xml_url
  validates_inclusion_of :feed_type, :in => [0, 1, nil], :message => "is not a valid type of feed"
  
  #CONSTANTS
  def self.RSS
    0
  end
  
  def self.ATOM
    1
  end
  
  #Helpers
  def feed_type_name
    if rss?
      "RSS"
    elsif atom?
      "Atom"
    else
      nil
    end
  end
  
  def rss?
    self.feed_type == Feed.RSS
  end
  
  def atom?
    self.feed_type == Feed.ATOM
  end
  
end
