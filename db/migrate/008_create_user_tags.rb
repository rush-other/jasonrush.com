class CreateUserTags < ActiveRecord::Migration
  def self.up
    create_table :user_tags do |t|
      t.column :tag_id, :integer, :null => false
      t.column :article_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end
    
    #Indexes
    add_index :user_tags, [:tag_id, :article_id, :user_id], :unique => true
    
    #Foreign Keys (For whole app since this is the last table to be created)
    ##User Tags##
    execute 'ALTER TABLE user_tags ADD CONSTRAINT fk_user_tags_tags FOREIGN KEY ( tag_id ) REFERENCES tags( id )'
    execute 'ALTER TABLE user_tags ADD CONSTRAINT fk_user_tags_articles FOREIGN KEY ( article_id ) REFERENCES articles( id )'
    execute 'ALTER TABLE user_tags ADD CONSTRAINT fk_user_tags_users FOREIGN KEY ( user_id ) REFERENCES users( id )'
    ##Folders##
    execute 'ALTER TABLE folders ADD CONSTRAINT fk_folders_users FOREIGN KEY ( user_id ) REFERENCES users( id )'
    ##User Feeds##
    execute 'ALTER TABLE user_feeds ADD CONSTRAINT fk_user_feeds_users FOREIGN KEY ( user_id ) REFERENCES users( id )'
    execute 'ALTER TABLE user_feeds ADD CONSTRAINT fk_user_feeds_folders FOREIGN KEY ( folder_id ) REFERENCES folders( id )'
    execute 'ALTER TABLE user_feeds ADD CONSTRAINT fk_user_feeds_feeds FOREIGN KEY ( feed_id ) REFERENCES feeds( id )'
    ##Articles##
    execute 'ALTER TABLE articles ADD CONSTRAINT fk_articles_feeds FOREIGN KEY ( feed_id ) REFERENCES feeds( id )'
    ##User Articles##
    execute 'ALTER TABLE user_articles ADD CONSTRAINT fk_user_articles_articles FOREIGN KEY ( article_id ) REFERENCES articles( id )'
    execute 'ALTER TABLE user_articles ADD CONSTRAINT fk_user_articles_users FOREIGN KEY ( user_id ) REFERENCES users( id )'
    
  end

  def self.down
    drop_table :user_tags
  end
end
