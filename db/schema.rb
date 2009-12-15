# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 10) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "link"
    t.text     "description"
    t.string   "guid"
    t.datetime "pub_date"
    t.text     "content"
    t.text     "full_text"
    t.integer  "feed_id",     :null => false
  end

  add_index "articles", ["feed_id"], :name => "index_articles_on_feed_id"
  add_index "articles", ["link"], :name => "index_articles_on_link"
  add_index "articles", ["guid"], :name => "index_articles_on_guid"

  create_table "feeds", :force => true do |t|
    t.string   "xml_url",                     :default => "", :null => false
    t.string   "html_url",                    :default => "", :null => false
    t.integer  "feed_type"
    t.string   "title",        :limit => 100
    t.text     "description"
    t.datetime "last_updated"
    t.datetime "last_queried"
  end

  add_index "feeds", ["xml_url"], :name => "index_feeds_on_xml_url", :unique => true

  create_table "folders", :force => true do |t|
    t.string  "title",   :limit => 50, :default => "",   :null => false
    t.boolean "active",                :default => true, :null => false
    t.integer "user_id",                                 :null => false
  end

  add_index "folders", ["user_id"], :name => "index_folders_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tags", :force => true do |t|
    t.string "tag", :limit => 50, :default => "", :null => false
  end

  add_index "tags", ["tag"], :name => "index_tags_on_tag", :unique => true

  create_table "user_articles", :force => true do |t|
    t.integer "article_id",                    :null => false
    t.integer "user_id",                       :null => false
    t.boolean "unread",     :default => false, :null => false
    t.integer "rating",     :default => 3,     :null => false
  end

  add_index "user_articles", ["article_id", "user_id"], :name => "index_user_articles_on_article_id_and_user_id", :unique => true
  add_index "user_articles", ["user_id"], :name => "fk_user_articles_users"

  create_table "user_feeds", :force => true do |t|
    t.integer "feed_id",                                      :null => false
    t.string  "title",       :limit => 100, :default => "",   :null => false
    t.text    "description"
    t.integer "folder_id"
    t.integer "user_id",                                      :null => false
    t.boolean "active",                     :default => true, :null => false
  end

  add_index "user_feeds", ["folder_id"], :name => "index_user_feeds_on_folder_id"
  add_index "user_feeds", ["user_id"], :name => "index_user_feeds_on_user_id"
  add_index "user_feeds", ["feed_id"], :name => "index_user_feeds_on_feed_id"

  create_table "user_tags", :force => true do |t|
    t.integer "tag_id",     :null => false
    t.integer "article_id", :null => false
    t.integer "user_id",    :null => false
  end

  add_index "user_tags", ["tag_id", "article_id", "user_id"], :name => "index_user_tags_on_tag_id_and_article_id_and_user_id", :unique => true
  add_index "user_tags", ["article_id"], :name => "fk_user_tags_articles"
  add_index "user_tags", ["user_id"], :name => "fk_user_tags_users"

  create_table "users", :force => true do |t|
    t.string  "username",                 :limit => 20, :default => "",   :null => false
    t.string  "password",                 :limit => 50, :default => "",   :null => false
    t.string  "first_name",               :limit => 50, :default => "",   :null => false
    t.string  "last_name",                :limit => 50, :default => "",   :null => false
    t.string  "email",                                  :default => "",   :null => false
    t.integer "paging_preference",                      :default => 25,   :null => false
    t.integer "article_view_preference",                :default => 0,    :null => false
    t.boolean "non_junk_only_preference",               :default => true, :null => false
    t.boolean "active",                                 :default => true, :null => false
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_view "vw_articles_for_users", "select `articles`.`id` AS `id`,`articles`.`title` AS `title`,`articles`.`link` AS `link`,`articles`.`description` AS `description`,`articles`.`content` AS `content`,`articles`.`guid` AS `guid`,`articles`.`pub_date` AS `pub_date`,`articles`.`full_text` AS `full_text`,`articles`.`feed_id` AS `feed_id`,`user_articles`.`id` AS `user_article_id`,`user_articles`.`user_id` AS `article_user_id`,`user_feeds`.`user_id` AS `feed_user_id`,`user_articles`.`unread` AS `unread`,`user_articles`.`rating` AS `rating`,`user_feeds`.`active` AS `active_feed`,`folders`.`id` AS `folder_id`,`folders`.`active` AS `active_folder` from (((`articles` left join `user_articles` on((`articles`.`id` = `user_articles`.`article_id`))) join `user_feeds` on((`articles`.`feed_id` = `user_feeds`.`feed_id`))) left join `folders` on((`folders`.`id` = `user_feeds`.`folder_id`))) order by `articles`.`pub_date` desc", :force => true do |v|
    v.column :id
    v.column :title
    v.column :link
    v.column :description
    v.column :content
    v.column :guid
    v.column :pub_date
    v.column :full_text
    v.column :feed_id
    v.column :user_article_id
    v.column :article_user_id
    v.column :feed_user_id
    v.column :unread
    v.column :rating
    v.column :active_feed
    v.column :folder_id
    v.column :active_folder
  end

end
