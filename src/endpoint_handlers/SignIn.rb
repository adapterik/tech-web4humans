require_relative './EndpointHandler'

class SignIn < EndpointHandler
  def initialize(context, input)
    super(context, input)
    @content_id = context[:arguments][0]
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
    # If have auth session, just return from whence we came...
    
    # Otherwise, we ask the user how they want to sign in:
    # 
    providers = @site_db.get_openid_providers

    # We now abstract the "page" to be anything that affects the overall 
    # and generic information about the page.
    @context[:page] = {
      'title' => 'Sign In'
    }

    content = {
      'title' => 'Sign In'
    }

    # Create the context object, which is a merging of
    # - the site, contemnt def, menu, etc. see below
    request = {
      ip: ENV['REMOTE_ADDR'],
      referrer: ENV['HTTP_REFERER'],
      ui: ENV['HTTP_USER_AGENT']
    }

    @context.merge!({
      site: @site,
      content: content,
      providers: providers,
      env: {
        request: request
      },
    })

    load_endpoint_template().result binding
  end
end
