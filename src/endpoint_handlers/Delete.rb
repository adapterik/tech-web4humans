require_relative './EndpointHandler'

class Delete < EndpointHandler
  

  #
  # The GET method displays the deletion form
  #
  def handle_get()
    ensure_can_edit

    # This allows the header to highlight the page being edited.
    edited_content_type_id = @context[:arguments][0]
    edited_content_id = @context[:arguments][1]

    return_path_success = @context[:params]['return_path_success']
    return_path_cancel = @context[:params]['return_path_cancel']

    @context[:content_id] = edited_content_id

    # Just to please the partials.
    @context[:content] = {
      'id' => edited_content_id,
      'title' => "Editing content item #{edited_content_id}"
    }

    # Here we set up a special context just for this 
    # endpoint

    content = @site_db.get_content edited_content_type_id, edited_content_id

    # TODO: the content type info can also be returned from query above,
    content_type = @site_db.get_content_type content['content_type']

    @data = {
      :content_id => edited_content_id,
      :content => content,
      :content_type => content_type,
      :return_path_success => return_path_success,
      :return_path_cancel => return_path_cancel
    }

    load_endpoint_template().result binding
  end

  def handle_delete(form_data) 
    ensure_can_edit
    content_type_id_to_delete = @context[:arguments][0]
    content_id_to_delete = @context[:arguments][1]

     @site_db.delete_content(content_type_id_to_delete, content_id_to_delete)

     ['', 302, {'location' => form_data['return_path']}]
  end

  def handle_post()
    ensure_can_edit

    form_data = URI.decode_www_form(@input.gets).to_h

    if not form_data.has_key? '_method'
      raise ClientError('Sorry, need a method')
    end

    fake_method = form_data['_method']
    case fake_method.downcase
    when 'delete'
      handle_delete(form_data)
    else 
      raise ClientError('Sorry, only "delete" supported')
    end
  end

end