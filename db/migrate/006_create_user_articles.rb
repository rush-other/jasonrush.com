class CreateUserArticles < ActiveRecord::Migration
  def self.up
    create_table :user_articles do |t|
      t.column :article_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :unread, :boolean, :null => false, :default => false
      #Rating is an enum of 1 to 5 stars
      t.column :rating, :integer, :null => false, :default => 3
    end
    
    #Indexes
    add_index :user_articles, [:article_id, :user_id], :unique => true
    
  end

  def self.down
    drop_table :user_articles
  end
end
