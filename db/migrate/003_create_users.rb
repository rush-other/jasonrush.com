class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :username, :string, :limit => 20, :null => false
      t.column :password, :string, :limit => 50, :null => false
      t.column :first_name, :string, :limit => 50, :null => false
      t.column :last_name, :string, :limit => 50, :null => false
      t.column :email, :string, :limit => 255, :null => false
      #User preferences
      t.column :paging_preference, :integer, :null => false, :default => 25
      t.column :article_view_preference, :integer, :null => false, :default => 0
      t.column :non_junk_only_preference, :boolean, :null => false, :default => true
      
      t.column :active, :boolean, :null => false, :default => true
    end
    
    #Indexes
    add_index :users, :username, :unique => true
    
    #Add a demo user - username/password -> demo/secret
    User.create(:username => "demo", 
                :password => "e5e9fa1ba31ecd1ae84f75caaa474f3a663f05f4", 
                :first_name => "Demo", 
                :last_name => "User", 
                :email => "jasonrush@jasonrush.com",
                :paging_preference => 25,
                :article_view_preference => 0,
                :non_junk_only_preference => true
                )
  end

  def self.down
    drop_table :users
  end
end
