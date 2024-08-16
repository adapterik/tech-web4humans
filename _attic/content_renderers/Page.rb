require 'erb' 
require 'kramdown'
require 'sqlite3'

# The job of the PageContent class is to fetch the given page from the 
# database, and return the appropriate html in the render method.

class ContentPage

  @@file_cache = {}
  @@template_cache = {}
  @@rendered_cache = {}

  def initialize(page_def, context)
    @page = page_def
    @context = context

    dir = File.dirname(File.realpath(__FILE__))
    # full_path_to_template = "#{dir}/templates/pages/#{@page[:template]}.html.erb"
    path = "#{dir}/../../data/site.sqlite3"
    @db = SQLite3::Database.new path
    @db.results_as_hash = true
  end


  def load_content(id)
    content_record = @db.execute 'select * from content where id = ?', id
    content_record[0]
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

  def render
    dir = File.dirname(File.realpath(__FILE__))
    # full_path_to_template = "#{dir}/templates/pages/#{@page[:template]}.html.erb"
    path = "#{dir}/templates/pages/ContentPage.html.erb"
    template = load_template(path)
    rendered = template.result binding
  end

end