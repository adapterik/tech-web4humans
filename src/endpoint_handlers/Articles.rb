require_relative './EndpointHandler'

class Articles < EndpointHandler
  def initialize(context, input)
    super(context, input)
    # In this case, the page content is the same as the endpoint
    @content_id = @context[:endpoint_name]
  end

  #
  # There is still page content, even though we are not using the Page 
  # renderer.
  #
  def include_content()
    template = ERB.new @context[:content]['content']
    fulfilled_content = template.result binding
    rendered = Kramdown::Document.new(fulfilled_content).to_html
    set_rendered(@context[:content_id], rendered)
  end

  def handle_get()
    #
    # Here we fetch the associated item
    #
    content = @site_db.get_content(@content_id)
  
    # If we can't find the content, we set the content to the "Not Found" content.
    if content.nil?
        original_content_id = @content_id
        content_id = 'not_found'
        content = @site_db.get_content(content_id)
        content[:original_content_id] = original_content_id
    end

    #
    # The a list of articles - which is all content items of content type "article"
    #

    articles = @site_db.list_content('article')

    # Create the context object, which is a merging of
    # - the site, page def, menu, etc. see below
    request = {
      ip: ENV['REMOTE_ADDR'],
      referrer: ENV['HTTP_REFERER'],
      ui: ENV['HTTP_USER_AGENT']
    }

    @context.merge!({
      site: @site,
      content_id: @content_id,
      content: content,
      articles: articles,
      env: {
        request: request
      },
    })

    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/../templates/endpoints/Articles.html.erb"
    template = load_template(path)
    template.result binding
  end
end