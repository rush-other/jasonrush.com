# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'lib/exceptions/access_denied_exception'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '9633b6cf968927d8e70568eef7e3b9b2'
  
  #Authenticate secure pages
  before_filter :authenticate
  
  #Layout
  layout 'main_frame'
  
private
  def authenticate
    if secure
      #This is a secure page, see if the user is logged in
      if logged_in_user_id.nil?
        #User is not logged in, go to the login page
        redirect_to :controller => 'user', :action => 'login', :format => 'html'
      end
    end
  end
  
  #Helpers
  def user_id_condition(table_name)
    #Returns the condition that the user_id for a record matches
    # the user_id of the logged in user
    if logged_in_user_id.nil?
      #This condition shouldn't be used without checking to
      # make sure that there is a logged in user first
      raise AccessDeniedException.new("Cannot add a user condition: logged in user is nil")
    else
      table_name + ".user_id = " + logged_in_user_id.to_s
    end
  end
  
  #Session Helpers
  
  #Get the logged in user ID from the session
  def logged_in_user_id
    session[:logged_in_user_id]
  end
  
  #Get the logged in user ID from the session and
  # resolve it to a User object
  def logged_in_user
    if logged_in_user_id.nil?
      nil
    else
      User.find(logged_in_user_id)
    end
  end
  
  #Return the selected article group (:all, :uncategorized, :folder-ID, :article-ID)
  def selected_article_group
    if session[:selected_article_group].blank?
      session[:selected_article_group] = {:type => :all, :id => nil}
    end
    group = session[:selected_article_group]
    type = group[:type]
    if type == :feed
      obj = UserFeed.find(group[:id])
    elsif type == :folder
      obj = Folder.find(group[:id])
    else
      #Type is :all or :uncategorized
      obj = nil
    end
    return type, obj
  end
  
  def selected_article_group_type
    if session[:selected_article_group].blank?
      session[:selected_article_group] = {:type => :all, :id => nil}
    end
    session[:selected_article_group][:type]
  end
  
  #Get the selected folder if applicable
  def selected_folder
    if selected_article_group_type != :folder
      nil
    else
      folder = Folder.find(selected_article_group[:id])
      #Make sure the folder is there and active, and that it belongs to the
      # logged in user (which should be a given, but just checking...)
      if folder.nil? || !folder.active || folder.user_id != logged_in_user_id
        #Default to showing all
        session[:selected_article_group] = {:type => :all, :id => nil}
        nil
      else
        folder
      end
    end
  end
  
  #Get the selected article if applicable
  def selected_feed
    if selected_article_group_type != :feed
      nil
    else
      feed = UserFeed.find(selected_article_group[:id])
      #Make sure the folder is there and active, and that it belongs to the
      # logged in user (which should be a given, but just checking...)
      if folder.nil? || !folder.active || folder.user_id != logged_in_user_id
        #Default to showing all
        session[:selected_article_group] = {:type => :all, :id => :nil}
        nil
      else
        feed
      end
    end
  end
end
