require_relative './EndpointHandler'

class Home < EndpointHandler
  def initialize(context, input)
    super(context, input)
    @tab = 'home'
    @content_id = 'home'
  end

  def include_content()
    template = ERB.new @context[:content]['content']
    fulfilled_content = template.result binding
    rendered = Kramdown::Document.new(fulfilled_content).to_html
    set_rendered(@context[:content_id], rendered)
  end

  def handle_get()
    # Here we fetch the associated item
    content = @site_db.get_system_page @content_id

    # If we can't find the content, we set the content to the "Not Found" content.
    if content.nil?
        original_content_id = @content_id
        content_id = 'not_found'
        content = @site_db.get_system_page content_id
        content[:original_content_id] = original_content_id
    end

    content_type = @site_db.get_content_type content['content_type']

    # We now abstract the "page" to be anything that affects the overall 
    # and generic information about the page.
    @context[:page] = {
      'title' => content['title']
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
      content_id: @content_id,
      content: content,
      content_type: content_type,
      env: {
        request: request
      },
    })

    load_endpoint_template().result binding
  end
end