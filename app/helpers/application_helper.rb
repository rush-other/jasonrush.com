# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #Constants
  DEFAULT_CSS = 'public/stylesheets/default.css'
  
  #Return the time stamp of the modification date for the default css
  def css_time_stamp
    return File.new(DEFAULT_CSS).mtime.to_i
  end
end
