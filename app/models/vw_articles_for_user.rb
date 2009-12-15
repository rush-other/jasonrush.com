class VwArticlesForUser < ActiveRecord::Base
  
  #Helpers
  def self.find_articles_for_user(obj, type, logged_in_user_id, limit = nil, page = nil)
    #Returns [articles, has_next_page]
    #Find one more than the limit to see if there is a next page
    if limit.nil?
      extra_limit = nil
    else
      extra_limit = limit+1
    end
    real_offset = offset(limit, page)
    #Get the list of articles
    articles = self.find(:all, self.find_articles_for_user_args(false, obj, type, logged_in_user_id, extra_limit, real_offset))
    #Determine if there is a previous or next page
    has_prev = !page.nil? && page > 1
    has_next = !limit.nil? && articles.size > limit
    #Drop the last item (used only to determine if additional pages exist)
    articles = articles[0, limit] if has_next
    #Figure out the title
    if type == :all
      title = "All Feeds"
    elsif type == :uncategorized
      title = "Uncategorized Feeds"
    else
      #obj is either a user feed, or a folder, either way, use it's title
      title = obj.title
    end
    #Return the paged list
    return PagedList.new(articles, has_prev, has_next, page, title)
  end
  def self.count_articles_for_user(obj, type, logged_in_user_id)
    self.count(self.find_articles_for_user_args(true, obj, type, logged_in_user_id, nil, nil))
  end
  
private
  def self.find_articles_for_user_args(count_only, obj, type, logged_in_user_id, limit, offset)
    #Set up arguments for UserArticle.find or UserArticle.count
    args = {}
    #Get distinct results
    if count_only
      args[:select] = "DISTINCT id"
    else
      args[:select] = "DISTINCT id, title, link, description, content, unread,user_article_id, rating"
    end
    #Set up the conditions by type and logged in user
    if type == :feed
      #Find all articles for the selected user_feed
      args[:conditions] = ["feed_id = ? AND (article_user_id = ? OR article_user_id IS NULL)", obj.feed_id, logged_in_user_id]
    elsif type == :uncategorized
      #Find all articles that are not categorized under a folder
      args[:conditions] = ["folder_id IS NULL AND active_feed = 1 AND feed_user_id = ? ", logged_in_user_id]
    elsif type == :folder
      #Find all articles for the selected folder
      args[:conditions] = ["active_feed = 1 AND folder_id = ?", obj.id]
    else
      #Type is :all, Find all articles for the logged in user
      args[:conditions] = ["active_feed = 1 AND feed_user_id = ?", logged_in_user_id]
    end
    #Setup the order by date
    args[:order] = "pub_date DESC"
    #If we are getting the actual results, not just a count, then page it
    unless count_only || limit.nil?
      args[:limit] = limit 
      args[:offset] = offset
    end
    return args
  end
  
  #Calculate the offset from the limit and the current page
  def self.offset(limit, page)
    if limit.nil?
      nil
    elsif page.nil?
      0
    else
      limit * (page-1)
    end
  end
  
  #Helper Class for returning articles list
  class PagedList < Array
    attr_accessor :has_prev_page, :has_next_page, :has_pages, :page, :prev_page, :next_page, :title
    
    def initialize(array, has_prev, has_next, page, title)
      super(array)
      @has_prev_page = has_prev
      @has_next_page = has_next
      @title = title
      if page.nil?
        @page = 1 #Default to 1
      else
        @page = page
      end
      @has_pages = has_prev || has_next
      @prev_page = @page-1 if has_prev
      @next_page = @page+1 if has_next
    end
  end
end