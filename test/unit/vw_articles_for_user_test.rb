require File.dirname(__FILE__) + '/../test_helper'

class VwArticlesForUserTest < Test::Unit::TestCase
  fixtures :articles, :user_articles, :folders, :feeds, :user_feeds

  #Test the creation of the find args - count only
  def test_count_find_articles_for_user_args_with_feed
    feed = UserFeed.find(5) #New York Times
    args = VwArticlesForUser.find_articles_for_user_args(true, feed, :feed, 3, nil, nil)
    assert args[:select] == "DISTINCT id"
    assert args[:conditions] == ["feed_id = ? AND (article_user_id = ? OR article_user_id IS NULL)", 4, 3]
    assert args[:order] == "pub_date DESC"
    assert args[:limit].blank?
    assert args[:offset].blank?
  end
  def test_count_find_articles_for_user_args_with_folder
    folder = Folder.find(4) #Devel
    args = VwArticlesForUser.find_articles_for_user_args(true, folder, :folder, 3, nil, nil)
    assert args[:select] == "DISTINCT id"
    assert args[:conditions] == ["active_feed = 1 AND folder_id = ?", 4]
    assert args[:order] == "pub_date DESC"
    assert args[:limit].blank?
    assert args[:offset].blank?
  end
  def test_count_find_articles_for_user_args_with_uncategorized
    args = VwArticlesForUser.find_articles_for_user_args(true, nil, :uncategorized, 3, nil, nil)
    assert args[:select] == "DISTINCT id"
    assert args[:conditions] == ["folder_id IS NULL AND active_feed = 1 AND feed_user_id = ? ", 3]
    assert args[:order] == "pub_date DESC"
    assert args[:limit].blank?
    assert args[:offset].blank?
  end
  def test_count_find_articles_for_user_args_with_all
    args = VwArticlesForUser.find_articles_for_user_args(true, nil, :all, 3, nil, nil)
    assert args[:select] == "DISTINCT id"
    assert args[:conditions] == ["active_feed = 1 AND feed_user_id = ?", 3]
    assert args[:order] == "pub_date DESC"
    assert args[:limit].blank?
    assert args[:offset].blank?
  end
  
  #Test the creation of the find args
  def test_find_articles_for_user_args_with_feed
    feed = UserFeed.find(8) #Digg
    args = VwArticlesForUser.find_articles_for_user_args(false, feed, :feed, 3, nil, nil)
    assert args[:select] == "DISTINCT id, title, link, description, content, unread,user_article_id, rating"
    assert args[:conditions] == ["feed_id = ? AND (article_user_id = ? OR article_user_id IS NULL)", 8, 3]
    assert args[:order] == "pub_date DESC"
    assert args[:limit].blank?
    assert args[:offset].blank?
  end
  def test_find_articles_for_user_args_with_folder
    folder = Folder.find(5) #Tech
    args = VwArticlesForUser.find_articles_for_user_args(false, folder, :folder, 3, nil, nil)
    assert args[:select] == "DISTINCT id, title, link, description, content, unread,user_article_id, rating"
    assert args[:conditions] == ["active_feed = 1 AND folder_id = ?", 5]
    assert args[:order] == "pub_date DESC"
    assert args[:limit].blank?
    assert args[:offset].blank?
  end
  def test_find_articles_for_user_args_with_uncategorized
    args = VwArticlesForUser.find_articles_for_user_args(false, nil, :uncategorized, 3, nil, nil)
    assert args[:select] == "DISTINCT id, title, link, description, content, unread,user_article_id, rating"
    assert args[:conditions] == ["folder_id IS NULL AND active_feed = 1 AND feed_user_id = ? ", 3]
    assert args[:order] == "pub_date DESC"
    assert args[:limit].blank?
    assert args[:offset].blank?
  end
  def test_find_articles_for_user_args_with_all
    #Include limit and offset for this one since there are a decent number of options returned
    args = VwArticlesForUser.find_articles_for_user_args(false, nil, :all, 3, 5, 5)
    assert args[:select] == "DISTINCT id, title, link, description, content, unread,user_article_id, rating"
    assert args[:conditions] == ["active_feed = 1 AND feed_user_id = ?", 3]
    assert args[:order] == "pub_date DESC"
    assert args[:limit] == 5
    assert args[:offset] == 5
  end
  
  #Test counting articles now
  def test_count_articles_for_user_with_feed
    feed = UserFeed.find(6) #NErr the Blog
    count = VwArticlesForUser.count_articles_for_user(feed, :feed, 3)
    assert count == 2
  end
  def test_count_articles_for_user_with_folder
    folder = Folder.find(6) #News
    count = VwArticlesForUser.count_articles_for_user(folder, :folder, 3)
    assert count == 4
  end
  def test_count_articles_for_user_with_uncategorized
    count = VwArticlesForUser.count_articles_for_user(nil, :uncategorized, 3)
    assert count == 1
  end
  def test_count_articles_for_user_with_all
    count = VwArticlesForUser.count_articles_for_user(nil, :all, 3)
    assert count == 11
  end
  
  #Test finding the articles
  def test_find_articles_for_user_with_feed
    feed = UserFeed.find(6) #Err the Blog
    articles = VwArticlesForUser.find_articles_for_user(feed, :feed, 3)
    assert articles.size == 2
    assert !articles.has_next_page
    assert !articles.has_prev_page
    assert articles.prev_page.nil?
    assert articles.next_page.nil?
    assert articles.page == 1
    assert_article_inclusion(articles, [5, 6])
  end
  def test_find_articles_for_user_with_folder
    folder = Folder.find(6) #News
    articles = VwArticlesForUser.find_articles_for_user(folder, :folder, 3)
    assert articles.size == 4
    assert !articles.has_next_page
    assert !articles.has_prev_page
    assert articles.prev_page.nil?
    assert articles.next_page.nil?
    assert articles.page == 1
    assert_article_inclusion(articles, [1, 2, 3, 4])
  end
  def test_find_articles_for_user_with_uncategorized
    articles = VwArticlesForUser.find_articles_for_user(nil, :uncategorized, 3)
    assert articles.size == 1
    assert !articles.has_next_page
    assert !articles.has_prev_page
    assert articles.prev_page.nil?
    assert articles.next_page.nil?
    assert articles.page == 1
    assert_article_inclusion(articles, [12])
  end
  def test_find_articles_for_user_with_all
    articles = VwArticlesForUser.find_articles_for_user(nil, :all, 3, 5, 2)
    assert articles.size == 5 #Should be paged to only include 5
    assert articles.has_next_page
    assert articles.has_prev_page
    assert articles.prev_page == 1
    assert articles.next_page == 3
    assert articles.page = 2
    assert_article_inclusion(articles, [2, 3, 4, 5, 6])
  end

private
  def assert_article_inclusion(articles, ids)
    articles.each do |article|
      assert ids.include?(article.id)
    end
  end
end
