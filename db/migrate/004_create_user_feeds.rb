class CreateUserFeeds < ActiveRecord::Migration
  def self.up
    create_table :user_feeds do |t|
      t.column :feed_id, :integer, :null => false
      #This is possibly overriden, not the same as the real feed title
      t.column :title, :string, :limit => 255, :null => false
      #This is possibly overriden, not the same as the real feed description
      t.column :description, :text
      t.column :folder_id, :integer
      t.column :user_id, :integer, :null => false
      t.column :active, :boolean, :null => false, :default => true
    end
    
    #Indexes
    add_index :user_feeds, :folder_id
    add_index :user_feeds, :user_id
    add_index :user_feeds, :feed_id
    
  end

  def self.down
    drop_table :user_feeds
  end
end
