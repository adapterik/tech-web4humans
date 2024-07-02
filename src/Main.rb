require "cgi"
require "json"
require 'kramdown'
require 'erb'
require_relative 'ContentPage'
# require_relative 'pages/Home'
# require_relative 'pages/Development'
# require_relative 'pages/PageNotFound'
# require_relative 'pages/Name'

# Gets a value out of a JSON compatible structure 
def get_property(keys, context)
  if keys.length == 0 or context.nil?
    context
  else
    key = keys[0]
    rest = keys[1..]
    if context.is_a? Array and key.is_a? Integer
      get_property rest, context[key]
    elsif context.is_a? Object and key.is_a? Symbol
      get_property rest, context[key]
    else
      raise InternalError.new("Property not supported for #{key}")
    end
  end
end

class NotFound < Exception
  def initialize(message)
    @message = message
  end

  def response
    [404, { 'Content-Type' => "text/plain" }, [
      "Sorry, page not found. "
    ]]
  end
end

class InternalError < Exception
  def initialize(message)
    @message = message
  end

  def response
    [500, { 'Content-Type' => "text/plain" }, [
      "Sorry, internal error"
    ]]
  end
end

# class Home
#   def initialize
#     @title = "Jazz & Democracy Australia"
#   end
# end

class Main
  def initialize(home_dir)
    @home_dir = home_dir
    # @home = Home.new

    @site = load_json('site')

    # The site map is the 
    @site_map = load_json('site-map')
  end

  def load_json(path)
    file = File.open("#{@home_dir}/data/#{path}.json")
    data = JSON.parse(file.read, symbolize_names: true)
    file.close
    data
  end

  def load_erb(path)
    file = File.open("#{@home_dir}/templates/#{path}.erb")
    data = file.read
    file.close
    data
  end

  #
  # Given a page path, find the page in the site map
  #
  # If the path is one element, just return the page definition
  #
  # If the path has two elements, merge the subpage indicated by the second element
  # into th page definition indicated by the first.
  #
  # def find_page(path, visited = [])
  #   if path == "/"
  #     path = "/home"
  #   end

  #   page_path = path.split('/')
  #   if page_path.length == 0
  #     raise InternalError.new('No path provided')
  #   end

  #   # The final path element may end in .html - strip it off
  #   if page_path.last.end_with? ".html"
  #     page_path.last.chomp! ".html"
  #   end

  #   page_path = page_path[1..].map do |element|
  #     element.to_sym
  #   end

  #   page_def = get_property(page_path, @site_map)

  #   page_def
  # end

  def find_page(app_id)
    # puts("FIND APP...")
    # puts(app_id)
    # puts(@site_map[:apps][app_id])
    @site_map[:apps][app_id]
  end

  def handle_request(path, env)
    path_list = path.downcase.split('/').select{ |item| item.length > 0 }

    # Obtain the app name from the first path element, or :home as the default
    if path_list.length == 0 
      app_id = :home
    else
      app_id = path_list[0].to_sym
    end 

    # The app's positional params, if any, are provided by the rest of the request path.
    path_params = path_list[1..]

    handle_page(app_id)

    # case path
    #   # Some actions...
    #   # Perhaps generalize to a rest handler with a root like
    #   # /api ??
    # when "/send-message"
    #   data = JSON.parse(env['rack.input'].gets, symbolize_names: true)
    #   message = Message.new @site, home_dir: @home_dir, url: @site[:sparkpost][:url], api_key: ENV['SPARKPOST_API_KEY']
    #   result = message.send data
    #   [JSON.dump(result), 'application/json']
    # else
    #   [handle_page(path), 'text/html; charset=UTF-8']
    # end
  end

  def handle_page(page_id)
    page = find_page(page_id)

    # If we can't find the page, we set the page to the "Not Found" page.
    if page.nil?
        # raise NotFound.new("Page not found: #{page_id}")
        original_page_id = page_id
        page_id = :not_found
        page = find_page(page_id)
        page[:original_page_id] = original_page_id
    end

    # Create the context object, which is a merging of
    # - the site, page def, menu, etc. see below
    request = {
      _ip: ENV['REMOTE_ADDR'],
      _referrer: ENV['HTTP_REFERER'],
      _ui: ENV['HTTP_USER_AGENT']
    }

    # Here we have a set of page attributes which may be deduced from
    # the page id, or otherwise set in the page definition in the 
    # site-map.json file.

    if not(page.has_key? :id)
      page[:id] = page_id
    end

    if not(page.has_key? :template)
      page[:template] = page_id.to_s
    end

    if not(page.has_key? :title)
      page_title = page_id.to_s.split('_').map {|word| word.capitalize}
      page[:title] = page_title.join(' ')
    end

    if not(page.has_key? :class_name)
      class_name  = page_id.to_s.split('_').map {|word| word.capitalize}
      page[:class_name] = class_name.join('')
    end


    context = {
      site: @site,
      page_id: page_id,
      env: {
        page_id: page[:template],
        page: page
      },
    }


    # only get the page class if the file exists...

    custon_page_class = nil

    if not custon_page_class.nil?

      page_class = page[:class_name]

      require_relative "pages/#{page_class}"

      class_obj = Object.const_get(page_class)

      # pages[page_id][:class].new(context).render
      class_obj.new(context).render
    else
      ContentPage.new(page, context).render
    end
  end

  def call(env)
    path = env['PATH_INFO']
    begin
      body, content_type = handle_request(path, env)
    rescue NotFound => not_found
      not_found.response
    else
      [200, {
        'content-type' => content_type,
      }, [body]]
    end
  end
end
