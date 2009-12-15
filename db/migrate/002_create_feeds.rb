class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.column :xml_url, :string, :limit => 255, :null => false
      t.column :html_url, :string, :limit => 255, :null => false
      #Feed Type is 0, 1, 2 or 3 for RSS .9, 1, 2, and Atom
      t.column :feed_type, :integer
      t.column :title, :string, :limit => 255
      t.column :description, :text
      #Last time the articles of the feed were updated
      t.column :last_updated, :datetime
      #Last time the articles of the feed were queried
      t.column :last_queried, :datetime
    end
    
    #Indexes
    add_index :feeds, :xml_url, :unique => true
  end

  def self.down
    drop_table :feeds
  end
end
