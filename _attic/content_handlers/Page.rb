require 'erb' 
require 'kramdown'
require_relative './ContentHandler'

class Page < ContentHandler
  def prepare_data
    # nothing special to do
  end
end