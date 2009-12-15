class UserTag < ActiveRecord::Base
  #Relationships
  belongs_to :user
  belongs_to :tag
  belongs_to :article
  
  #Validations
  validates_presence_of :user_id
  validates_presence_of :tag_id
  validates_presence_of :article_id
  validates_uniqueness_of :tag_id, :scope => [:user_id, :article_id]
end
