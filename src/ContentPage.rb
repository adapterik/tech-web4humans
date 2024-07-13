require 'erb' 
require 'kramdown'

class ContentPage

  @@file_cache = {}
  @@template_cache = {}
  @@rendered_cache = {}

  def initialize(page_def, context)
    @page = page_def
    @context = context
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

  def render
    dir = File.dirname(File.realpath(__FILE__))
    # full_path_to_template = "#{dir}/templates/pages/#{@page[:template]}.html.erb"
    # we always render content with the content page template
    path = "#{dir}/templates/pages/ContentPage.html.erb"
    template = load_template(path)

    # We need to fetch the content

    # then get the content type from it

    # then we can load the appropriate renderer 

    # Then render with the renderer

    # or perhaps we'll fetch the content in a Content instance,
    # which either renders depending on the content type, or 
    # punts to the appropriate content type render (class)

    #content = Content.new()


    #"<div>HI!</div>"



    template.result binding
  end

  def include_partial(partial_name)
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/templates/partials/#{partial_name}.html.erb"
    template = load_template(path)
    rendered = template.result binding
    set_rendered(path, rendered)
  end

  def include_markdown(file_name)
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/data/content/#{file_name}.md"
    if is_rendered?(path)
      return get_rendered(path)
    end

    content = load_file(path)
    rendered = Kramdown::Document.new(content).to_html
    set_rendered(path, rendered)
  end

  def include_content2()
    #dir = File.dirname(File.realpath(__FILE__))
    #path = "#{dir}/data/content/#{@page[:template]}.md"
    #if is_rendered?(path)
      #return get_rendered(path)
    #end
    #template = load_template(path)


    #$puts(@context[:content_item])

    template = ERB.new @context[:content_item]['content']
    fulfilled_content = template.result binding
    rendered = Kramdown::Document.new(fulfilled_content).to_html
    set_rendered(@context [:content_id], rendered)
  end


  def include_content()
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/data/content/#{@page[:template]}.md"
    if is_rendered?(path)
      return get_rendered(path)
    end
    template = load_template(path)
    fulfilled_content = template.result binding
    rendered = Kramdown::Document.new(fulfilled_content).to_html
    set_rendered(path, rendered)
  end
end