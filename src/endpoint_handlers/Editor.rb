require_relative './EndpointHandler'

class Editor < EndpointHandler
  # def initialize(context, input)
  #   super(context)
  #   # if @context[:arguments].length == 0
  #   #   @page_id = 'home'
  #   # else
  #   #   @page_id = context[:arguments][0]
  #   # end
  # end

  # def include_page_content()
  #   template = ERB.new @context[:page]['content']
  #   fulfilled_content = template.result binding
  #   rendered = Kramdown::Document.new(fulfilled_content).to_html
  #   set_rendered(@context[:page_id], rendered)
  # end
  # 
  
  def ensure_can_edit()
    # Ensure authenticated session that can edit.
    if @context[:session].nil?
      raise ClientErrorUnauthorized.new
    end
    if @context[:session]["can_edit"] == 0
      raise ClientErrorForbidden.new
    end
  end

  #
  # The GET method displays the editor form
  #
  def handle_get()
    ensure_can_edit

    content_type_id = @context[:arguments][0]

    # This allows the header to highlight the page being edited.
    edited_content_id = @context[:arguments][1]

    return_path = @context[:params]['return_path']

    @context[:content_id] = edited_content_id

    # Just to please the partials.
    @context[:content] = {
      'id' => edited_content_id,
      'title' => "Editing content item #{edited_content_id}"
    }

    # Here we set up a special context just for this 
    # endpoint

    content = @site_db.get_content content_type_id, edited_content_id

    # TODO: the content type info can also be returned from query above
    content_type = @site_db.get_content_type content_type_id

    @data = {
      :content_id => edited_content_id,
      :content => content,
      :content_type => content_type,
      :return_path => return_path
    }

    load_endpoint_template().result binding
  end

  def handle_post()
    ensure_can_edit

    edited_content_type_id = @context[:arguments][0]

    edited_content_id = @context[:arguments][1]

    form_data = URI.decode_www_form(@input.gets).to_h

    # TODO: validate all data!
    
    if not form_data.has_key? '_method'
      raise ClientError('Sorry, need a method')
    end

    fake_method = form_data['_method']

    case fake_method.downcase
    when 'post'
      @site_db.add_content form_data
    when 'put'
      @site_db.update_content edited_content_type_id, edited_content_id, form_data 
    when 'patch'
      @site_db.patch_content edited_content_type_id, edited_content_id, form_data 
    else
      raise ClientError('Sorry, only "put" and "post" supported')
    end 

   

    # content = @site_db.get_content(edited_content_id)

    # ['', 302, {'location' => "/#{content['content_type']}/#{edited_content_id}"}]
    ['', 302, {'location' => form_data['return_path']}]
  end
end