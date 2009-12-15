require 'digest/sha1'

class User < ActiveRecord::Base
  #Relationships
  has_many :folders, :conditions => "active = 1"
  has_many :user_feeds, :conditions => "active = 1"
  has_many :user_articles
  has_many :user_tags
  
  #Validations
  validates_presence_of :username
  validates_presence_of :password
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :paging_preference
  validates_presence_of :article_view_preference
  validates_length_of :username, :maximum => 20
  validates_length_of :password, :maximum => 50
  validates_length_of :first_name, :maximum => 50
  validates_length_of :last_name, :maximum => 50
  validates_length_of :email, :maximum => 255
  validates_uniqueness_of :username
  validates_inclusion_of :article_view_preference, :in => [0, 1], :message => "is not a valid view preference."
  
  #Extensions
  acts_as_inactivatable
  
  #Constants
  #Article View Preference Constants
  def self.HEADER_ONLY
    0
  end
  def self.HEADER_AND_SUMMARY
    1
  end
  
  #Password helper
  def self.encrypt_password(pwd)
    Digest::SHA1.hexdigest(pwd)
  end
end
