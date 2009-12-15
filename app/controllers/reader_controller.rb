require 'lib/exceptions/mutually_exclusive_exception'

class ReaderController < ApplicationController
  def home
    setup_folder_map
    setup_selected_articles_and_pages
  end
  
  #Ajax functions
  def expand_collapse
    #See if the uncategorized one is being expanded/collapsed
    if params[:uncategorized]
      session[:expand_uncategorized] = !uncategorized_folder_expanded
    else
      #Otherwise, see what folder is being expanded/collapsed
      unless params[:id].blank?
        #Initialize the folder list if it hasn't been already
        session[:expanded_folder_list] = [] if session[:expanded_folder_list].blank?
        if session[:expanded_folder_list].include?(params[:id].to_i)
          #Expanded already, collapse it
          session[:expanded_folder_list].delete(params[:id].to_i)
        else
          #Collapsed, expand it
          session[:expanded_folder_list] << params[:id].to_i
        end
      end
    end
    setup_folder_map
    render(:partial => 'partials/folder_list', :locals => {:folders => @folder_map, :uncategorized => @uncategorized})
  end
  
  def refresh_articles
    #Cast the parameters
    if params[:type].blank?
      type = nil
    else
      type = params[:type].to_sym
    end
    if params[:id].blank?
      id = nil
    else
      id = params[:id].to_i
    end
    #Setup the selected article group in the session
    set_selected_article_group(type, id)
    #Get the paged articles list
    setup_selected_articles_and_pages
    render(:partial => 'partials/article_list', :locals => {:articles => @selected_articles})
  end
  
  #Expand and collapse an article
  def expand_article
    raise "No article" if params[:article].blank?
    article = Article.find(params[:article])
    raise "No article" if article.nil?
    render(:partial => "partials/expanded_article", :locals => {:article => article})
  end
  def collapse_article
    raise "No article" if params[:article].blank?
    article = Article.find(params[:article])
    raise "No article" if article.nil?
    render(:partial => "partials/collapsed_article", :locals => {:article => article})
  end
  
  #Popup dialog actions
  def do_subscribe
  #TODO - Validate URL and folder_id (for acl - logged in user)
  #  Then, make sure it is a valid feed by querying
  #  it (either for a feed, or crawling the page for
  #  for a feed), then save the feed for the user
    puts params[:url]
    puts params[:folder_id]
  end
  
private
  #This whole controller is secure
  def secure
    true
  end
  
  #Return true if this folder should be shown as expanded
  def folder_expanded(folder_id)
    return false if folder_id.nil? || session[:expanded_folder_list].blank?
    return session[:expanded_folder_list].include?(folder_id)
  end
  
  #Determine if the uncategorized folder should be
  # expanded to show all uncategorized feeds
  def uncategorized_folder_expanded
    return session[:expand_uncategorized] == true
  end
  
  def setup_folder_map
    #Set up the folder map for the folder_list partial
    folders = Folder.find_active(:conditions => user_id_condition(Folder.table_name), :include => :user_feeds)
    @folder_map = {}
    folders.each do |folder|
      unless folder.user_feeds.blank?
        @folder_map[folder.title] = {:id => folder.id }
        if folder_expanded(folder.id)
          @folder_map[folder.title][:feeds] = folder.user_feeds
        end
      end
    end
    @uncategorized = UserFeed.find_active(:conditions => user_id_condition(UserFeed.table_name) + " and folder_id is null")
  end
  
  def set_selected_article_group(type, id)
    unless type.nil?
      #Don't change the session if there is no type change
      session[:selected_article_group] = {:type => type, :id => id}
    end
  end
  
  #Get the selected articles and page count
  def setup_selected_articles_and_pages
    #Setup the page and the articles list
    @page = determine_page
    @selected_articles = selected_articles(@page)
  end
  
  #Determine what page you are on
  def determine_page
    if params[:first]
      1
    elsif params[:page].nil?
      1
    else
      params[:page].to_i
    end
  end
  
  #Get the list of selected articles
  def selected_articles(page)
    type, obj = selected_article_group
    limit = session[:paging_preference]
    limit = 25 if limit.nil?  #Default page size
    return VwArticlesForUser.find_articles_for_user(obj, type, logged_in_user_id, limit, page)
  end
end
