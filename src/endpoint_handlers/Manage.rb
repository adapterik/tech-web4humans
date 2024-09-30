require_relative './EndpointHandler'

class Manage < EndpointHandler
  def initialize(context, input)
    super(context, input)
    @content_id = context[:endpoint_name]
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
    ensure_can_manage

    # We now abstract the "page" to be anything that affects the overall 
    # and generic information about the page.
    content = @site_db.get_system_page @content_id
    content_type = @site_db.get_content_type 'system_page'

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
      content_item: content, 
      content_type: content_type,
      env: {
        request: request
      },
    })

    load_endpoint_template().result binding
  end

  def handle_remove_all_other_sessions(form_data)
    session_id = @context[:session]['id']
    @site_db.remove_all_other_sessions(session_id)

    @context[:content] = {
      'title' => 'All Other Sessions Removed'
    }

    @alert = {
      type: 'success',
      title: 'All Other Sessions Successfully Removed',
      content: 'All sessions, if any, other than this one have been removed from the site.',
      return_path: form_data['success_return_path']
    }

    load_page_template('Alert').result binding
  end

  def handle_remove_all_sessions(form_data)
    @site_db.remove_all_sessions()

    @context[:content] = {
      'title' => 'All Other Sessions Removed'
    }

    @alert = {
      type: 'success',
      title: 'All Sessions Successfully Removed',
      content: 'All sessions, if any, have been removed from the site. All users, including you, have been logged out.',
      return_path: form_data['success_return_path']
    }

    ['', 302, {'location' => "/"}]
    # load_page_template('Alert').result binding
  end

  def handle_post()
    ensure_can_manage

    form_data = URI.decode_www_form(@input.gets).to_h

    if not form_data.has_key? '_method'
      raise ClientError('Sorry, need a method')
    end

    action = @context[:arguments][0]

    fake_method = form_data['_method']
    case fake_method.downcase
    when 'delete'
      case action
      when 'remove_all_other_sessions'
        handle_remove_all_other_sessions form_data
      when 'remove_all_sessions'
        handle_remove_all_sessions form_data
      end
    else 
      raise ClientError('Sorry, only "delete" supported')
    end
  end
end
