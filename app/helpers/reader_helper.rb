module ReaderHelper
  #Get the page title for the current page
  def page_title
    "Feed Reader"
  end
  
  #Render the plus or minus icon
  def render_plus_minus_icon(expanded, update, url)
    if expanded
      image = "minus.gif"
      alt = "Collapse"
    else
      image = "plus.gif"
      alt = "Expand"
    end
    link_to_remote(image_tag(image), :update => update, :url => url)
  end
  
  #Determine if the uncategorized folder should be
  # expanded to show all uncategorized feeds
  def uncategorized_folder_expanded?
    session[:expand_uncategorized] = false if session[:expand_uncategorized].blank?
    return session[:expand_uncategorized]
  end
end
