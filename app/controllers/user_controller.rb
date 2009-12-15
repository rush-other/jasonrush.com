require 'lib/utils/string_utils'

class UserController < ApplicationController
  #List of secure pages in this controller
  SECURE = []
  
  def login
  end
  
  def do_login
    errors = []
    if params['username'].blank? || params['password'].blank?
      #Required fields missing, return to form
      flash[:errors] = ["Please enter a username and password"]
      flash[:username] = params[:username]
      #Clear out the logged in user in the session
      set_user_in_session(nil)
      redirect_to :action => 'login'
    else
      #Required fields are there, authenticate
      encrypted_password = User.encrypt_password(params['password'])
      username = StringUtils.sterilize_user_input(params['username'], :string)
      users = User.find_active(:conditions => "username = '" + username + "' and password = '" + encrypted_password + "'")
      if users.nil? || users.empty?
        flash[:errors] = "Incorrect username or password"
        flash[:username] = params['username']
        #Clear out the logged in user in the session
        set_user_in_session(nil)
        redirect_to :action => 'login'
      else
        #User validated!
        set_user_in_session(users.first)
        redirect_to :controller => 'reader', :action => 'home'
      end
    end
  end
  
private
  def secure
    SECURE.include?(action_name)
  end
  
  #Setup user in session
  def set_user_in_session(user)
    if user.nil?
      #Clear out session
      session[:logged_in_user_id] = nil
      set_user_preferences_in_session(nil, nil, nil)
    else
      #Set up session
      session[:logged_in_user_id] = user.id
      set_user_preferences_in_session(user.paging_preference, 
                                      user.article_view_preference, 
                                      user.non_junk_only_preference)
    end
  end
  
  def set_user_preferences_in_session(paging, article_view, non_junk_only)
    session[:paging_preference] = paging
    session[:article_view_preference] = article_view
    session[:non_junk_only_preference] = non_junk_only
  end
end
