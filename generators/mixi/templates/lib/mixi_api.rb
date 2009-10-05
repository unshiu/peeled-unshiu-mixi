require 'json'

class MixiAPI
  def self.register(owner_json, viewer_json, friends_json)
    viewer_data = parse_json(viewer_json)
    viewer = MixiUser.create_or_update(viewer_data)
    
    if owner_json.nil?
      owner = viewer
    else
      owner_data = parse_json(owner_json)
      owner = MixiUser.create_or_update(owner_data)
    end
    
    if owner.joined_at.nil?
      owner.joined_at = Time.now
      owner.save
    end
    
    unless friends_json.nil?
      friends_data = parse_json(friends_json)
      friends_data.values.each do |friend_data|
        user = MixiUser.create_or_update(friend_data)
        viewer.mixi_friends << user unless viewer.mixi_friends.member?(user)
      end
    end
  end
  
  private
  def self.parse_json(data)
    data.is_a?(Hash) ? data : JSON.parse(data, :create_additions => false)
  end
  
  class RESTHandler
    def initialize(requester_id)
      @connection = connection(requester_id)
    end
    
    def person(guid = '@me')
      p = OpenSocial::FetchPersonRequest.new(@connection, guid).send
      convert(parse_json(p.to_json))
    end
    
    def friends(guid = '@me')
      p = OpenSocial::FetchPeopleRequest.new(@connection, guid).send
      data = parse_json(p.to_json)
      data.each do |k, v|
        data[k] = convert(v)
      end
    end
    
    def people(guid = '@me', selector = '@friends', params = nil)
      p = OpenSocial::FetchPeopleRequest.new(@connection, guid, selector).send(params)
      parse_json(p.to_json)
    end
    
    def activities(guid = '@me', selector = '@self', pid = '@app')
      a = OpenSocial::FetchActivityRequest.new(@connection, guid, selector, pid).send
      parse_json(a.to_json)
    end
    
    def appdata(guid = '@me', selector = '@self', pid = '@app')
      a = OpenSocial::FetchAppDataRequest.new(@connection, guid, selector, pid).send
      parse_json(a.to_json)
    end
    
    def post_activity(data)
      OpenSocial::PostActivityRequest.new(@connection).send(data)
    end
    
    def post_appdata(data)
      OpenSocial::PostAppDataRequest.new(@connection).send(data)
    end
    
    private
    def connection(requester_id)
      consumer_key = AppResources[:mixi][:consumer_key]
      consumer_secret = AppResources[:mixi][:consumer_secret]
      container = {
        :endpoint => AppResources[:mixi][:endpoint],
        :content_type => 'application/json',
        :rest => ''
      }
      OpenSocial::Connection.new(:container => container,
                                 :consumer_key => consumer_key,
                                 :consumer_secret => consumer_secret,
                                 :xoauth_requestor_id => requester_id)
    end
    
    def parse_json(data)
      JSON.parse(data, :create_additions => false)
    end
    
    def convert(hash)
      {
        'mixi_id' => hash['id'].split(':').last,
        'nickname' => hash['nickname'],
        'thumbnail_url' => hash['thumbnail_url']
      }
    end
  end
end
