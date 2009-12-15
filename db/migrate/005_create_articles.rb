class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.column :title, :string, :limit => 255
      t.column :link, :string, :limit => 255
      t.column :description, :text
      t.column :guid, :string, :limit => 255
      t.column :pub_date, :datetime
      t.column :content, :text
      t.column :full_text, :text, :limit => 1.gigabytes
      t.column :feed_id, :integer, :null => false
    end
    
    #Indexes
    add_index :articles, :feed_id
    add_index :articles, :link
    add_index :articles, :guid
    
  end

  def self.down
    drop_table :articles
  end
end
