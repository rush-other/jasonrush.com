class UserArticle < ActiveRecord::Base
  #Relationships
  belongs_to :user
  belongs_to :article
  
  #Validations
  validates_presence_of :article_id
  validates_presence_of :user_id
  validates_presence_of :rating
  validates_uniqueness_of :article_id, :scope => :user_id
  validates_inclusion_of :rating, :in => 1..5, :message => "is not a valid rating."
  
end
