require "cgi"
require "json"
require 'kramdown'
require 'erb'
require 'sqlite3'
require 'uri'
require 'securerandom'
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

class ClientError < Exception
  def initialize(message)
    @message = message
  end

  def response
    [400, { 'Content-Type' => "text/plain" }, [
      @message
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
    @site_map[:apps][app_id]
  end


  def open_db()
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/../data/site.sqlite3"
    db = SQLite3::Database.new path
    db.results_as_hash = true
    db
  end

  def create_session(user_id) 
    session_id = SecureRandom.uuid
    db = open_db()
    now = Time.now.to_i
    db.execute 'insert into auth_sessions (id, user_id, created, expires) values (?, ?, ?, ?)', [session_id, user_id, now, now]
    session_id
  end

  def remove_session(session_id)
    db = open_db()
    db.execute 'delete from auth_sessions where id = ?', [session_id]
  end

  def get_session(session_id)
    db = open_db()
    session = db.execute 'select * from auth_sessions where id = ?', [session_id]
    session[0]
  end

  def find_content(content_id)
    db = open_db()
    content_record = db.execute 'select * from content where id = ?', content_id.to_s
    db.close
    content_record[0]
  end

  def handle_get(path, context)
    if path.length == 0 
      app_id = :home
    else
      app_id = path[0].to_sym
    end 
    handle_content(app_id, context)
  end

  def handle_post(path, context, env)
    if path.length == 0
      # do an error
      puts 'ERROR - no path for POST'
      raise ClientError.new('ERROR - no path for POST')
    end

    case env['CONTENT_TYPE']
    when 'application/json'
      data = JSON.parse(env['rack.input'].gets, symbolize_names: true)
    when 'application/x-www-form-urlencoded'
      data = URI.decode_www_form(env['rack.input'].gets)
    else
      raise ClientError.new("ERROR - content type not supported #{env['HTTP_CONTENT_TYPE']}")
    end

    case path[0]
      when 'authenticate'
        username = data.assoc('username').last
        password = data.assoc('password').last
        handle_authentication(username, password)
      when 'signout'
        if context[:session].nil?
          raise ClientError.new('Sorry, cannot logout since not logged in!')
        end
        handle_logout(context[:session]["id"])
      else
        puts 'ERROR - path not handled'
        puts path
        raise ClientError.new("ERROR - path not handled: #{path[0]}")
      end

  end

  def get_user_auth(username, password)
    db = open_db()
    authorization_record = db.execute 'select * from users_auth where user_id = ? and password = ?', [username, password]
    db.close
    if authorization_record.length == 0
      nil
    else 
      authorization_record[0]
    end
  end

  def handle_authentication(username, password)
    auth = get_user_auth(username, password)
    if auth.nil?
      raise ClientError.new 'Sorry, incorrect username and/or password'
    end

    # create session
    session_id = create_session(username)

    # set session cookie and redirect to ... home page for now.
    # two week expireation for login token...
    expires = 1000 * 60 * 60 * 24 * 2;
    [
      'Congrats, you have been logged in',
      'text/plain',
      {
        'Set-Cookie': "sid=#{session_id};path=/;expires=#{expires}"
      }
    ]
  end

  def handle_logout(session_id)
    remove_session(session_id)
    [
      'Congrats, you have been logged out',
      'text/plain',
      {
        'Set-Cookie': "sid=;path=/;expires=0"
      }
    ]
  end

  def handle_content(content_id, context)
    content_item = find_content(content_id)
    page = {}

    # If we can't find the page, we set the page to the "Not Found" page.
    if content_item.nil?
        # raise NotFound.new("Page not found: #{page_id}")
        original_content_id = content_id
        content_id = :not_found
        content_item = find_content(content_id)
        content_item[:original_content_id] = original_content_id
    end

    # Create the context object, which is a merging of
    # - the site, page def, menu, etc. see below
    request = {
      ip: ENV['REMOTE_ADDR'],
      referrer: ENV['HTTP_REFERER'],
      ui: ENV['HTTP_USER_AGENT']
    }

    # Here we have a set of page attributes which may be deduced from
    # the page id, or otherwise set in the page definition in the 
    # site-map.json file.

    if not(content_item.has_key? :id)
      content_item[:id] = content_id
    end

    if not(content_item.has_key? :template)
      content_item[:template] = content_id.to_s
    end

    if not(content_item.has_key? "title")
      page_title = content_id.to_s.split('_').map {|word| word.capitalize}
      page["title"] = page_title.join(' ')
      content_item["title"] = page_title.join(' ')
    end

    if not(content_item.has_key? :class_name)
      class_name  = content_id.to_s.split('_').map {|word| word.capitalize}
      content_item[:class_name] = class_name.join('')
    end

    context.merge!({
      site: @site,
      content_id: content_id,
      content_item: content_item,
      env: {
        page_id: page[:template],
        page: page,
        request: request
      },
    })

    # only get the page class if the file exists...

    custom_page_class = nil

    if not custom_page_class.nil?
      page_class = page[:class_name]
      require_relative "pages/#{page_class}"
      class_obj = Object.const_get(page_class)
      class_obj.new(context).render
    else
      ContentPage.new(page, context).render
    end
  end

  def handle_request(path, env)
    uri = URI.parse(path)
    path_list = uri.path.downcase.split('/').select{ |item| item.length > 0 }

    # extract from cookies.
    # auth session from cookie
    cookies = CGI::Cookie.parse(env['HTTP_COOKIE'])
    puts cookies
    if cookies.has_key? 'sid'
      session_id = cookies['sid']
      session = get_session(session_id)
      puts 'SESSION'
      puts session
    else
      session = nil 
    end

    context = {
      :session => session
    }

    case env['REQUEST_METHOD']
    when 'GET'
      handle_get(path_list, context)
    when 'POST'
      handle_post(path_list, context, env)
    else
      raise ClientError.new("ERROR - request method not handled: #{env['REQUEST_METHOD']}")
    end
  end

  def call(env)
    path = env['PATH_INFO']
    begin
      body, content_type, header = handle_request(path, env)
    rescue NotFound => not_found
      not_found.response
    rescue ClientError => client_error
      client_error.response
    else
      if header.nil?
        header = {}
      end 
      header['content-type'] = content_type
      [200, header, [body]]
    end
  end
end
