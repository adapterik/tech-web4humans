require 'erb' 
require 'kramdown'
require_relative './ContentHandler'

class ContentEditor < ContentHandler
  def prepare_data
    content_id = @context[:params]['content_id']
    content = @site_db.get_content(content_id)
    @data = {
      :foo => "BAR",
      :content => content
    }
  end
end