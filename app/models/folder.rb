class Folder < ActiveRecord::Base
  #Relationships
  belongs_to :user
  has_many :user_feeds, :conditions => "user_feeds.active = 1", :order => "user_feeds.title"
  
  #Validations
  validates_presence_of :title
  validates_presence_of :user_id
  validates_length_of :title, :maximum => 50
  
  #Extensions
  acts_as_inactivatable
  
  #Helpers
  
  #Make this folder inactive (cascade to user feeds)
  #Do this with alias method chain
  def inactivate_with_feeds
    inactivate_without_feeds
    unless user_feeds.nil?
      user_feeds.each do |feed|
        #Nullify the folder relationship
        feed.folder_id = nil
        feed.save
      end
    end
    self.save
  end
  
  #In this version of inactivate we want to include the
  # breaking of the feed relationship
  alias_method_chain :inactivate, :feeds
end
