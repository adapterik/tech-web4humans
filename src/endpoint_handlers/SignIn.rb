require_relative './EndpointHandler'

class SignIn < EndpointHandler
  def initialize(context, input)
    super(context, input)
    # should be "signin"
    @content_id = context[:endpoint_name]
    @content_type_id = 'system_page'
    @tab = @content_id
  end

  def include_part(part_content_id)
    part = @site_db.get_content('part', part_content_id)

    template = ERB.new part['content']
    fulfilled_content = template.result binding
    rendered = Kramdown::Document.new(fulfilled_content).to_html
    set_rendered(part_content_id, rendered)
  end

  def handle_get()
    content = @site_db.get_content(@content_type_id, @content_id)
    if content.nil?
      raise NotFound.new("Resource not found: #{@context[:path]}")
    end
    content_type = @site_db.get_content_type @content_type_id


    # If have auth session, just return from whence we came...
    
    # Otherwise, we ask the user how they want to sign in:
    # 
    providers = @site_db.get_openid_providers

    # We now abstract the "page" to be anything that affects the overall 
    # and generic information about the page.
    @context[:page] = {
      'title' => 'Sign In'
    }

    # content = {
    #   'title' => 'Sign In'
    # }

    # Create the context object, which is a merging of
    # - the site, contemnt def, menu, etc. see below
    request = {
      ip: ENV['REMOTE_ADDR'],
      referrer: ENV['HTTP_REFERER'],
      ui: ENV['HTTP_USER_AGENT']
    }

    @context.merge!({
      site: @site,
      content_id: @content_id,
      content: content,
      content_type: content_type,
      providers: providers,
      env: {
        request: request
      },
    })

    load_endpoint_template().result binding
  end
end
