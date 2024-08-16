require 'erb' 
require 'kramdown'

class Page
  @title = "YOUR TITLE HERE"
  @template_name = "YOUR TEMPLATE HERE"

  def initialize(context)
    @context = context
  end

  class << self
    attr_accessor :title
    attr_accessor :template_name
  end

  def load_file(path)
    file = File.open(path, 'r:UTF-8')
    data = file.read
    file.close
    data
  end

  def render
    dir = File.dirname(File.realpath(__FILE__))
    full_path_to_template = "#{dir}/templates/pages/#{self.class.template_name}.html.erb"
    erb = load_file(full_path_to_template)
    template = ERB.new erb
    template.result binding
  end

  def include_partial(template_file_name)
    dir = File.dirname(File.realpath(__FILE__))
    full_path_to_template = "#{dir}/templates/partials/#{template_file_name}.html.erb"
    erb = load_file(full_path_to_template)
    template = ERB.new erb
    template.result binding
  end
  
  def include_markdown(file_name)
    dir = File.dirname(File.realpath(__FILE__))
    full_path_to_template = "#{dir}/data/content/#{file_name}.md"
    content = load_file(full_path_to_template)
    Kramdown::Document.new(content).to_html
  end
end
