require 'net/https'
require 'uri'
require 'json'
require 'pp'

class Playbasis

  BASE_URL = 'https://api.pbapp.net/'
  BASE_ASYNC_URL = 'https://api.pbapp.net/async/'

  def initialize
    @token = ''
    @api_key_param = ''
    @resp_channel = ''
  end

  def auth(api_key, api_secret)
    @api_key_param = "?api_key=#{api_key}"
    result = call('Auth', {  :api_key => api_key,
                :api_secret => api_secret })
    @token = result['response']['token']
    @token.is_a? String
  end

  def renew(api_key, api_secret)
    @api_key_param = "?api_key=#{api_key}"
    result = call('Auth/renew', {  :api_key => api_key,
                             :api_secret => api_secret })
    @token = result['response']['token']
    @token.is_a? String
  end

  def set_ssync_response_channel(channel)

      uri = URI.parse(BASE_ASYNC_URL + 'channel/verify/' + channel)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      result = http.request(request)

      if result.body == 'true'
          @resp_channel = channel
          return true
      end
      false
  end

  def player(player_id)
    call("Player/#{player_id}", { :token => @token })
  end

  # player_list_id player id as used in client's website separate with ',' example '1,2,3'
  def player_list(player_list_id)
    call("Player/list", { :token => @token, :list_player_id => player_list_id })
  end

  def player_detail(player_id)
    call("Player/#{player_id}/data/all", { :token => @token })
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
  def register_async(player_id, username, email, image_url, optional_data={})
    call_async("Player/#{player_id}/register", {
        :token => @token,
        :username => username,
        :email => email,
        :image => image_url
    }.merge(optional_data), @resp_channel)
  end

  # @param  update_data  Key-value for data to be updated.
  #               The following keys are supported:
  #               - username
  #							  - email
  #							  - image
  #							  - exp
  #							  - level
  #               - facebook_id
  #               - twitter_id
  #               - password    assumed hashed
  #               - first_name
  #               - last_name
  #               - nickname
  #               - gender    1=Male, 2=Female
  #               - birth_date  format YYYY-MM-DD
  def update(player_id, update_data={})
    call("Player/#{player_id}/update", {
        :token => @token
    }.merge(update_data))
  end
  def update_async(player_id, update_data={})
    call_async("Player/#{player_id}/update", {
        :token => @token
    }.merge(update_data), @resp_channel)
  end

  def delete(player_id)
    call("Player/#{player_id}/delete", { :token => @token })
  end
  def delete_async(player_id)
    call_async("Player/#{player_id}/delete", { :token => @token }, @resp_channel)
  end

  def login(player_id)
    call("Player/#{player_id}/login", { :token => @token })
  end
  def login_async(player_id)
    call_async("Player/#{player_id}/login", { :token => @token }, @resp_channel)
  end
    
  def logout(player_id)
    call("Player/#{player_id}/logout", { :token => @token })
  end
  def logout_async(player_id)
    call_async("Player/#{player_id}/logout", { :token => @token }, @resp_channel)
  end

  def points(player_id)
    call("Player/#{player_id}/points" + @api_key_param)
  end

  def point(player_id, point_name)
    call("Player/#{player_id}/point/#{point_name}" + @api_key_param)
  end

  def point_history(player_id, point_name='', offset=0, limit=20)
    string_query = "&offset=#{offset}&limit=#{limit}"
    if point_name != ''
        string_query = "#{string_query}&point_name=#{point_name}"
    end
    call("Player/#{player_id}/point_history" + @api_key_param + string_query)
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
  
  def rank(ranked_by, limit=20)
    call("Player/rank/#{ranked_by}/#{limit}" + @api_key_param)
  end

  def ranks(limit=20)
    call("Player/ranks/#{limit}" + @api_key_param)
  end

  def level(level)
    call("Player/level/#{level}" + @api_key_param)
  end

  def levels
    call('Player/levels' + @api_key_param)
  end

  def claim_badge(player_id, badge_id)
    call("Player/#{player_id}/badge/#{badge_id}/claim", { :token => @token })
  end

  def redeem_badge(player_id, badge_id)
    call("Player/#{player_id}/badge/#{badge_id}/redeem", { :token => @token })
  end

  def goods_owned(player_id)
    call("Player/#{player_id}/goods" + @api_key_param)
  end

  def quest_of_player(player_id, quest_id)
    call("Player/quest/#{quest_id}"+@api_key_param+"&player_id=#{player_id}")
  end

  def quest_list_of_player(player_id)
    call('Player/quest'+@api_key_param+"&player_id=#{player_id}")
  end
  
  def badges
    call('Badge' + @api_key_param)
  end
  
  def badge(badge_id)
    call("Badge/#{badge_id}" + @api_key_param)
  end

  def goods
    call('Goods' + @api_key_param)
  end

  def goods_list(goods_id)
    call("Goods/#{goods_id}" + @api_key_param)
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
  def rule_async(player_id, action, optional_data={})
    call_async('Engine/rule', {
        :token => @token,
        :player_id => player_id,
        :action => action
    }.merge(optional_data), @resp_channel)
  end

  def quests
    call('Quest' + @api_key_param)
  end

  def quest(quest_id)
    call("Quest/#{quest_id}" + @api_key_param)
  end

  def mission(quest_id, mission_id)
    call("Quest/#{quest_id}/mission/#{mission_id}" + @api_key_param)
  end

  def quests_available(player_id)
    call('Quest/available/' + @api_key_param + "&player_id=#{player_id}")
  end

  def quest_available(quest_id, player_id)
    call("Quest/#{quest_id}/available/" + @api_key_param + "&player_id=#{player_id}")
  end

  def join_quest(quest_id, player_id)
    call("Quest/#{quest_id}/join", { :token => @token, :player_id => player_id})
  end
  def join_quest_async(quest_id, player_id)
    call_async("Quest/#{quest_id}/join", { :token => @token, :player_id => player_id}, @resp_channel)
  end

  def cancel_quest(quest_id, player_id)
    call("Quest/#{quest_id}/cancel", { :token => @token, :player_id => player_id})
  end
  def cancel_quest_async(quest_id, player_id)
    call_async("Quest/#{quest_id}/cancel", { :token => @token, :player_id => player_id}, @resp_channel)
  end

  def redeem_goods(goods_id, player_id, amount=1)
    call('Redeem/goods', { :token => @token, :goods_id => goods_id, :player_id => player_id, :amount => amount})
  end
  def redeem_goods_async(goods_id, player_id, amount=1)
    call_async('Redeem/goods', { :token => @token, :goods_id => goods_id, :player_id => player_id, :amount => amount}, @resp_channel)
  end

  def recent_point(offset=0, limit=10)
    call("Service/recent_point#{@api_key_param}&offset=#{offset}&limit=#{limit}")
  end
  
  def recent_point_by_name(point_name, offset=0, limit=10)
    call("Service/recent_point#{@api_key_param}&offset=#{offset}&limit=#{limit}&point_name=#{point_name}")
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

  def call_async(method, data=nil, response_channel=nil)

    uri = URI.parse(BASE_ASYNC_URL + 'call')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    if data
      body = []
      body['endpoint'] = method
      body['data'] = data
      if response_channel
          body['channel'] = response_channel
      end
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(body)
    else
      request = Net::HTTP::Get.new(uri.request_uri)
    end
    result = http.request(request)
    JSON.parse(result.body)
  end
end
