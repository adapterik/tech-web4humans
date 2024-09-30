require 'sqlite3'
require 'securerandom'

class SiteDB 
  def initialize()
    dir = File.dirname(File.realpath(__FILE__))
    path = "#{dir}/../data/site.sqlite3"
    @path = path
    @db = open_db()
    @session = nil
  end

  def open_db()
    db = SQLite3::Database.new @path
    db.results_as_hash = true
    db
  end

  def set_session(session)
    @session = session
  end

  def get_user_auth(username, password)
    authorization_record = @db.execute 'select * from users_auth where user_id = ? and password = ?', [username, password]
    # db.close
    if authorization_record.length == 0
      nil
    else 
      authorization_record[0]
    end
  end

  def create_session(user_id) 
    session_id = SecureRandom.uuid
    now = Time.now.to_i
    expires = now + 60 * 60 * 24 * 14
    @db.execute 'insert into auth_sessions (id, user_id, created, expires) values (?, ?, ?, ?)', [session_id, user_id, now, expires]
    session_id
  end

  def remove_session(session_id)
    @db.execute 'delete from auth_sessions where id = ?', [session_id]
  end

  def remove_all_other_sessions(session_id)
    @db.execute 'delete from auth_sessions where id != ?', [session_id]
  end


  def remove_all_sessions()
    @db.execute 'delete from auth_sessions', []
  end

  def get_session(session_id)
    query = "
      select 
        s.id as session_id,
        s.user_id as user_id,
        u.name as user_name,
        u.can_view as can_view,
        u.can_edit as can_edit,
        u.can_manage as can_manage
      from auth_sessions s, users u 
      where s.id = ? and s.user_id = u.id 
    "
    session = @db.execute query, [session_id]
    session[0]
  end

  def list_content(content_type, sort)

    order_by = ''

    if not sort.nil? or sort.length > 0
      column = sort[0]
      direction = if sort[1].start_with?('a')
        'ASC'
      else
        'DESC'
      end
      order_by += "order by #{column} #{direction}"
    end
    
    query = "
      select
        c.*
      from content c
      where
        c.content_type = ?
      #{order_by}
    "
    content_list = @db.execute query, [content_type]
    content_list
  end


  def search_content(content_type, sort, search_text)
    order_by_clause = ''

    if not sort.nil? or sort.length > 0
      column = sort[0]
      direction = if sort[1].start_with?('a')
        'ASC'
      else
        'DESC'
      end
      order_by_clause += "order by #{column} #{direction}"
    end

    where_clause = 'where c.content_type = ? and c.status_id = s.id'
    query_params = [content_type]

    if not search_text.nil?
      where_clause += ' and (c.content like ? or c.title like ?)'
      query_params.push("%#{search_text}%", "%#{search_text}%")
    end

    # If we are authenticated, we see everything, otherwise, just published.
    # Remember, authentication is only used for managing the site, so we can
    # make this simplifying assumption. Otherwise, we could, with little more work,
    # simply look at the user's authorization.
    
    if @session.nil?
      where_clause += " and c.status_id = 'published'"
    end
    
    
    query = "
      select
        c.*, s.description as status
      from content c, content_status s
      #{where_clause}
      #{order_by_clause}
    "
    content_list = @db.execute query, query_params
    content_list
  end

  def get_content_type(content_type_id)
    query = "
      select 
       t.*
      from content_types t 
      where 
        t.id = ?
    "
    content_record = @db.execute query, [content_type_id]
    content_record[0]
  end

  def get_content(content_type, content_id)
    query = "
      select 
        c.*, t.class, t.noun as noun
      from content c, content_types t 
      where 
        c.content_type = t.id and 
        c.content_type = ? and
        c.id = ? 
    "
    content_record = @db.execute query, [content_type, content_id]
    content_record[0]
  end

  def get_page(id)
    get_content 'page', id
  end

  def get_system_page(id)
    get_content 'system_page', id
  end

  def delete_content(content_type, content_id)
    query = "
      delete 
      from content
      where 
        content_type = ? and
        id = ?
    "
    @db.execute query, [content_type, content_id]
  end

  def update_content(content_type, content_id, changes)
    # TODO: apply rules to fields
    
    id = changes['id']
    title = changes["title"]
    content = changes["content"]
    content_type = changes["content_type"]

    last_updated = (Time.now.to_f).to_i
      
    query = "
      update content
      set id = ?, title = ?, content = ?, last_updated = ?, content_type = ?
      where content.content_type = ? and content.id = ?
    "
    @db.execute query, [id, title, content, last_updated, content_type, content_type, content_id]
  end


  def patch_content(content_type, content_id, submitted_changes)
    changes = []
    params = []

    field_white_list = ['status_id']

    field_white_list.each do |name|
      if submitted_changes.has_key? name
        changes.push "#{name} = ?"
        params.push submitted_changes[name]
      end
    end

    if changes.length == 0
      return
    end

    last_updated = (Time.now.to_f).to_i

    changes.push 'last_updated = ?'
    params.push last_updated

    params.push content_type
    params.push content_id
      
    query = "
      update content
      set #{changes.join ', '}
      where content.content_type = ? and content.id = ?
    "
    @db.execute query, params
  end

  def add_content(content_item)
    id = content_item["id"]
    title = content_item["title"]
    content = content_item["content"]
    author = content_item["author"]
    created = (Time.now.to_f).to_i
    last_updated = created
    content_type = content_item["content_type"]

    query = "
      insert into content 
      (id, title, content, author, created, last_updated, content_type, status_id)
      values
      (?, ?, ?, ?, ?, ?, ?, 'draft')
    "
    @db.execute query, [id, title, content, author, created, last_updated, content_type]

    get_content content_type, id
  end

  def get_endpoint(name, arity)
    record = @db.execute 'select e.name, e.description as endpoint_description, i.class, i.description as description from endpoints e, endpoint_instances i where i.name = e.name and i.name = ? and i.arity = ?', [name, arity]
    if record.length === 0
      get_endpoint('page', 1)
    else 
      record[0]
    end
  end

  def get_site()
    record = @db.execute 'select * from site'
    return record[0]
  end

  # openid auth
  
  def get_openid_providers()
     result = @db.execute 'select * from openid_providers'
     result
  end

  def get_openid_provider(provider_id)
    result = @db.execute 'select * from openid_providers where id = ?', [provider_id]
    result[0]
  end
end