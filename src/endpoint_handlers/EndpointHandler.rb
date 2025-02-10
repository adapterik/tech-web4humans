require 'erb' 
require 'kramdown'
require 'kramdown-parser-gfm'
require 'rouge'
require_relative '../SiteDB'
require_relative '../responses'

class EndpointHandler
  @@file_cache = {}
  @@template_cache = {}
  @@rendered_cache = {}

  def initialize(context, input)
    @context = context
    @input = input

    @header = {}
    @data = {}
    @site = {}
    @site_db =  SiteDB.new()
    @site_db.set_session context[:session]
  end
  
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
  
  def load_endpoint_template(name=nil)
    template_name = name.nil? ? self.class.name : name
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/../templates/endpoints/#{template_name}.html.erb"
    load_template path
  end

  def make_template_name(suffix = '')
    base_name = self.class.name 
    "#{base_name}#{suffix}"
  end
  
  def load_page_template(name)
    template_name = name.nil? ? self.class.name : name
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/../templates/pages/#{template_name}.html.erb"
    load_template path
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

  def can_edit?()
    # Ensure authenticated session that can edit.
    @context[:session] && @context[:session]["can_edit"] == 1
  end 

  def can_manage?()
    # Ensure authenticated session that can edit.
    @context[:session] && @context[:session]["can_manage"] == 1
  end

  def ensure_authorization(authorization)
    if @context[:session].nil?
      raise ClientErrorUnauthorized.new
    end
    if @context[:session][authorization] == 0
      raise ClientErrorForbidden.new
    end
  end

  def ensure_can_edit()
    ensure_authorization('can_edit')
  end

  def ensure_can_manage()
    ensure_authorization('can_manage')
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
    # rendered = Kramdown::Document.new(fulfilled_content, :syntax_highlighter => 'rouge').to_html
    rendered = Kramdown::Document.new(fulfilled_content).to_html
    set_rendered(@context [:content_id], rendered)
  end

  # def get_data()
  #   # Extract the POSTed data
  #   case env['CONTENT_TYPE']
  #   when 'application/json'
  #     data = JSON.parse(env['rack.input'].gets, symbolize_names: true)
  #   when 'application/x-www-form-urlencoded'
  #     data = URI.decode_www_form(env['rack.input'].gets)
  #   else
  #     raise ClientError.new("ERROR - content type not supported #{env['HTTP_CONTENT_TYPE']}")
  #   end
  # end
  
  def handle_get()
    raise ClientErrorMethodNotAllowed.new 'GET'
  end

  def handle_post()
    raise ClientErrorMethodNotAllowed.new "POST #{self.class.name}"
  end

  def handle_put()
    raise ClientErrorMethodNotAllowed.new 'PUT'
  end

  def handle_delete()
    raise ClientErrorMethodNotAllowed.new 'DELETE'
  end
  
  def render()
    case @context[:method]
    when 'GET'
      handle_get()
    when 'POST'
      handle_post()
    when 'PUT'
      handle_put()
    when 'DELETE'
      handle_delete()
    else
      raise ClientErrorMethodNotAllowed.new("ERROR - request method not handled: #{@context[:method]}")
    end
  end
end