module UserHelper
  #Get the page title for the current page
  def page_title
    if controller.action_name == 'login'
      "Feed Weeder - Login"
    else
      "Feed Weeder"
    end
  end
end
