module OPMLUtils
  #Helpers
  def self.import_opml(opml_doc, logged_in_user_id)
    #Parse the XML from an imported OPML file.  Creates
    # folders, feeds and user_feeds as needed (does not
    # duplicate existing folders, feeds or user_feeds)
    # The parameter 'opml_doc' is assumed to be an REXML
    # document that follows the OPML specification and
    # contains information about RSS and Atom feeds.
    opml_doc.elements.each("opml/body/outline") do |node|
      parse_opml_node(node, nil, logged_in_user_id)
    end
  end

private
  #TODO - This is a bit inefficient right now.
  def self.parse_opml_node(node, parent_folder, logged_in_user_id)
    #Parses the node.  If the node represents a folder,
    # and the folder contains at least one feed, creates
    # a Folder instance.  If the node represents a feed,
    # creates a Feed instance if applicable and creates
    # a UserFeed instance.
    if node.elements.blank?
      #This is an article
      if node.attributes["xmlUrl"].blank? ||
        node.attributes["htmlUrl"].blank? ||
        node.attributes["type"].blank?
        #Oops!  Can't have a feed without these items
      else
        xml_url = node.attributes["xmlUrl"]
        html_url = node.attributes["htmlUrl"]
        #See if the feed already exists
        feed = Feed.find(:first, :conditions => "xml_url = '" + xml_url + "'")
        if feed.nil?
          feed = Feed.new
          feed.xml_url = xml_url
        end
        feed.html_url = html_url
        feed.title = node.attributes["title"]
        feed.save
        #See if the user feed already exists for this user
        user_feed = UserFeed.find(:first, :conditions => "feed_id = " + feed.id.to_s + " and user_id = " + logged_in_user_id.to_s)
        if user_feed.nil?
          user_feed = UserFeed.new
          user_feed.feed_id = feed.id
          user_feed.user_id = logged_in_user_id
        end
        user_feed.title = feed.title
        user_feed.description = feed.title
        user_feed.active = true
        user_feed.folder = parent_folder
        user_feed.save
      end
    else
      #This is a folder
      #Make sure this is a valid folder
      if not node.attributes["title"].blank?
        #See if this folder has any feeds.  If it is only nested folders, 
        # don't do anything except recurse.  No nested folders.
        node.elements.each do |element|
          folder = nil
          if not element.attributes["xmlUrl"].blank?
            #This node has feed children, do it
            #First, see if this already exists
            folder = Folder.find(:first, :conditions => "title = '" + node.attributes["title"] + "' and user_id = " + logged_in_user_id.to_s)
            if folder.nil?
              folder = Folder.new
              folder.title = node.attributes["title"]
              folder.user_id = logged_in_user_id
            end
            folder.active = true
          end
          node.elements.each do |element|
            #Recurse on each element
            parse_opml_node(element, folder, logged_in_user_id)
          end
        end
      end
    end
  end
end