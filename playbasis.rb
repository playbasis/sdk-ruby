require 'net/https'
require 'uri'
require 'json'
require 'pp'

class Playbasis

  BASE_URL = 'https://api.pbapp.net/'

  def initialize
    @token = ''
    @api_key_param = ''
  end

  def auth(api_key, api_secret)
    @api_key_param = "?api_key=#{api_key}"
    result = call('Auth', {  :api_key => api_key,
                :api_secret => api_secret })
    @token = result['response']['token']
    @token.is_a? String
  end

  def player(player_id)
    call("Player/#{player_id}", { :token => @token })
  end

  # @param  optional_data  Key-value for additional parameters to be sent to the register method.
  #               The following keys are supported:
  #               - facebook_id
  #               - twitter_id
  #               - password    assumed hashed
  #               - first_name
  #               - last_name
  #               - nickname
  #               - gender    1=Male, 2=Female
  #               - birth_date  format YYYY-MM-DD
  def register(player_id, username, email, image_url, optional_data={})
    call("Player/#{player_id}/register", {
      :token => @token,
      :username => username,
      :email => email,
      :image => image_url
      }.merge(optional_data))
  end

  def login(player_id)
    call("Player/#{player_id}/login", { :token => @token })
  end
    
  def logout(player_id)
    call("Player/#{player_id}/logout", { :token => @token })
  end

  def points(player_id)
    call("Player/#{player_id}/points" + @api_key_param)
  end

  def point(player_id, point_name)
    call("Player/#{player_id}/point/#{point_name}" + @api_key_param)
  end

  def action_last_performed(player_id)
    call("Player/#{player_id}/action/time" + @api_key_param)
  end
  
  def action_last_performed_time(player_id, action_name)
    call("Player/#{player_id}/action/#{action_name}/time" + @api_key_param)
  end
  
  def action_performed_count(player_id, action_name)
    call("Player/#{player_id}/action/#{action_name}/count" + @api_key_param)
  end
  
  def badge_owned(player_id)
    call("Player/#{player_id}/badge" + @api_key_param)
  end
  
  def rank(ranked_by, limit)
    call("Player/rank/#{ranked_by}/#{limit}" + @api_key_param)
  end
  
  def badges
    call('Badge' + @api_key_param)
  end
  
  def badge(badge_id)
    call("Badge/#{badge_id}" + @api_key_param)
  end
  
  def badge_collections
    call('Badge/collection' + @api_key_param)
  end
  
  def badge_collection(collection_id)
    call("Badge/collection/#{collection_id}" + @api_key_param)
  end
  
  def action_config
    call('Engine/actionConfig' + @api_key_param)
  end

  # @param  optional_data  Key-value for additional parameters to be sent to the rule method.
  #               The following keys are supported:
  #               - url    url or filter string (for triggering non-global actions)
  #               - reward  name of the custom-point reward to give (for triggering rules with custom-point reward)
  #               - quantity  amount of points to give (for triggering rules with custom-point reward)
  def rule(player_id, action, optional_data={})
    call('Engine/rule', {
      :token => @token,
      :player_id => player_id,
      :action => action
      }.merge(optional_data))
  end

  def call(method, data=nil)
    
    uri = URI.parse(BASE_URL + method)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    if data
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(data)
    else
      request = Net::HTTP::Get.new(uri.request_uri)
    end
    result = http.request(request)
    JSON.parse(result.body)
  end
end
