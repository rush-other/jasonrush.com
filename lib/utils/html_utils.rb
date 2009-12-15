module HTMLUtils
  #Strip the HTML tags from a string
  def self.strip_html_tags(str)
    #Replace all tags with white space (strip out dup spaces then)
    return str.gsub(/<(.|\n)+?>/, " ").strip.gsub(/\s+/, " ")
  end
end