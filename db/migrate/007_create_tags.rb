class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :tag, :string, :limit => 50, :null => false
    end
    
    #Indexes
    add_index :tags, :tag, :unique => true
  end

  def self.down
    drop_table :tags
  end
end
