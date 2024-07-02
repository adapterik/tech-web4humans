require 'erb' 
require 'kramdown'

class ContentPage

  def initialize(page_def, context)
    @page = page_def
    @context = context
  end

  def load_file(path)
    file = File.open(path, 'r:UTF-8')
    data = file.read
    file.close
    data
  end

  def render
    dir = File.dirname(File.realpath(__FILE__))
    # full_path_to_template = "#{dir}/templates/pages/#{@page[:template]}.html.erb"
    full_path_to_template = "#{dir}/templates/pages/ContentPage.html.erb"
    erb = load_file(full_path_to_template)
    template = ERB.new erb
    template.result binding
  end

  def include_partial(partial_name)
    dir = File.dirname(File.realpath(__FILE__))
    full_path_to_template = "#{dir}/templates/partials/#{partial_name}.html.erb"
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

  def include_content_markdown()
    dir = File.dirname(File.realpath(__FILE__))
    full_path_to_markdown = "#{dir}/data/content/#{@page[:template]}.md"
    puts(full_path_to_markdown)
    content = load_file(full_path_to_markdown)

    template = ERB.new content

    fulfilled_content = template.result binding

    Kramdown::Document.new(fulfilled_content).to_html
  end
end