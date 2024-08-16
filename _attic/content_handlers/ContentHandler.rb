require 'erb' 
require 'kramdown'
require_relative '../SiteDB'

class ContentHandler
  @@file_cache = {}
  @@template_cache = {}
  @@rendered_cache = {}

  def initialize(content, context)
    @header = {}
    @content = content
    @context = context
    @data = {}
    @site_db =  SiteDB.new()
  end

  # def remove_cookie(cookie_name)
  #   @header['Set-Cookie', "#{cookie_name};path=/;expires=0"]
  # end
  # 
  
  def set_header(name, value)
    @header[name] = value
  end

  def load_file(path)
    if @@file_cache.has_key? path
      return @@file_cache[path]
    end

    file = File.open(path, 'r:UTF-8')
    data = file.read
    file.close
    @@file_cache[path] = data
    data
  end

  def load_template(path)
    if @@template_cache.has_key? path
      return @@template_cache[path]
    end

    erb = load_file(path)
    template = ERB.new erb
    @@template_cache[path] = template
    template
  end

  def is_rendered?(path)
    @@rendered_cache.has_key? path
  end
  
  def get_rendered(path)
    if @@rendered_cache.has_key? path
      return @@rendered_cache[path]
    end
    nil
  end
  
  def set_rendered(path, rendered)
    @@rendered_cache[path] = rendered
    rendered
  end

  def include_partial(partial_name)
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/../templates/partials/#{partial_name}.html.erb"
    template = load_template(path)
    rendered = template.result binding
    set_rendered(path, rendered)
  end

  def include_content()
    template = ERB.new @context[:content_item]['content']
    fulfilled_content = template.result binding
    rendered = Kramdown::Document.new(fulfilled_content).to_html
    set_rendered(@context [:content_id], rendered)
  end

  def render
    prepare_data
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/../templates/pages/#{self.class.name}.html.erb"
    template = load_template(path)
    template.result binding
  end

  def prepare_data
    # Does nothing by default.
  end
end