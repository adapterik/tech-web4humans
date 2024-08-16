require 'erb' 
require 'kramdown'
require_relative './ContentHandler'

class Deauthenticate < ContentHandler
  def prepare_data
    @site_db.remove_session(session_id)
    @data = {
      :content => 'Congrats, you have been logged out',
    }
    @header['Set-Cookie', "#{cookie_name};path=/;expires=0"]
    set_header('Set-Cookie', 'sid=;path=/;expires=0')
    
    # remove_cookie('sid')
    # [
    #   'Congrats, you have been logged out',
    #   'text/plain',
    #   {
    #     'Set-Cookie': "sid=;path=/;expires=0"
    #   }
    # ]

    # @data = {
    #   :foo => "BAR",
    #   :content => content
    # }
  end
end