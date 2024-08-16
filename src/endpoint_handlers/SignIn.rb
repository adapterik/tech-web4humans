require_relative './EndpointHandler'

class SignIn < EndpointHandler
  def initialize(context, input)
    super(context, input)
    @content_id = context[:arguments][0]
    @tab = @content_id
  end

  def include_part(part_content_id)
    part = @site_db.get_content(part_content_id)

    template = ERB.new part['content']
    fulfilled_content = template.result binding
    rendered = Kramdown::Document.new(fulfilled_content).to_html
    set_rendered(part_content_id, rendered)
  end

  def handle_get()
    # tab = @context[:arguments][0]

    # content_type_id = case tab
    # when 'pages' 
    #   'page'
    # when 'articles' 
    #   'article'
    # when 'blog'
    #   'blog'
    # when 'thoughts' 
    #   'thought'
    # when 'projects' 
    #   'project'
    # end

    # # Here we fetch the associated item
    # content = @site_db.get_content(@content_id)
  
    # # If we can't find the content, we set the content to the "Not Found" content.
    # if content.nil?
    #     original_content_id = @content_id
    #     content_id = 'not_found'
    #     content = @site_db.get_content(content_id)
    #     content[:original_content_id] = original_content_id
    #     content_list = []
    # else
    #     content_list = @site_db.list_content(content_type_id)
    #     puts 'HMM'
    #     puts content_type_id
    #     puts content_list.length
    # end

    # @content_type = content_type_id

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
      # content_id: @content_id,
      content: content,
      # content_list: content_list,
      env: {
        request: request
      },
    })

    dir = File.dirname(File.realpath(__FILE__))
    # class_name = content['content_type'].capitalize
    path = "#{dir}/../templates/endpoints/SignIn.html.erb"
    template = load_template(path)
    template.result binding
  end
end