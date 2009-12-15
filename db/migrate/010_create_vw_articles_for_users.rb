class CreateVwArticlesForUsers < ActiveRecord::Migration
  def self.up
    #Create the view
    view_sql =
      <<-eos
          SELECT  articles.id as id,
              articles.title as title,
              articles.link as link,
              articles.description as description,
              articles.content as content,
              articles.guid as guid,
              articles.pub_date as pub_date,
              articles.full_text as full_text,
              articles.feed_id as feed_id,
              user_articles.id as user_article_id,
              user_articles.user_id as article_user_id,
              user_feeds.user_id as feed_user_id,
              user_articles.unread as unread,
              user_articles.rating as rating,
              user_feeds.active as active_feed,
              folders.id as folder_id,
              folders.active as active_folder
            FROM articles
            LEFT JOIN user_articles ON articles.id = user_articles.article_id
            INNER JOIN user_feeds ON articles.feed_id = user_feeds.feed_id
            LEFT JOIN folders ON folders.id = user_feeds.folder_id
            ORDER BY articles.pub_date DESC
      eos
      
    create_view :vw_articles_for_users, view_sql do |v|
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

  def self.down
#    drop_view :vw_articles_for_users
  end
end
