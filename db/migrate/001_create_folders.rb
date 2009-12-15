class CreateFolders < ActiveRecord::Migration
  def self.up
    #Create table
    create_table :folders do |t|
      t.column :title, :string, :limit => 50, :null => false
      t.column :active, :boolean, :null => false, :default => true
      t.column :user_id, :integer, :null => false
    end
    
    #Indexes
    add_index :folders, :user_id
    
  end

  def self.down
    drop_table :folders
  end
end
