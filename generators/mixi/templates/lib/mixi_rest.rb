class MixiREST
  def self.register(con, viewer_id, owner_id = nil)
    viewer_data = JSON.parse(person(con), :create_additions => false)
    viewer = MixiUser.create_or_update(convert(viewer_data))
    
    if owner_id.nil?
      owner = viewer
    else
      owner_data = JSON.parse(person(con, owner_id), :create_additions => false)
      owner = MixiUser.create_or_update(convert(owner_data))
    end
    
    if owner.joined_at.nil?
      owner.joined_at = Time.now
      owner.save
    end
    
    friends_data = JSON.parse(friends(con), :create_additions => false)
    friends_data.values.each do |friend_data|
      user = MixiUser.create_or_update(convert(friend_data))
      viewer.mixi_friends << user unless viewer.mixi_friends.member?(user)
    end
    
    [viewer, owner]
  end
  
  def self.convert(hash)
    {
      'mixi_id' => hash['id'].split(':').last,
      'nickname' => hash['nickname'],
      'thumbnail_url' => hash['thumbnail_url']
    }
  end
  
  def self.connection(requester_id)
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
  
  def self.person(con, guid = '@me', selector = '@self')
    OpenSocial::FetchPersonRequest.new(con, guid, selector).send.to_json
  end
  
  def self.friends(con, guid = '@me')
    OpenSocial::FetchPeopleRequest.new(con, guid).send.to_json
  end
  
  def self.people(con, guid = '@me', selector = '@friends')
    OpenSocial::FetchPeopleRequest.new(con, guid, selector).send.to_json
  end
  
  def self.activities(con, guid = '@me', selector = '@self', pid = '@app')
    OpenSocial::FetchActivityRequest.new(con, guid, selector, pid).send.to_json
  end
  
  def self.appdata(con, guid = '@me', selector = '@self', pid = '@app')
    OpenSocial::FetchAppDataRequest.new(con, guid, selector, pid).send.to_json
  end
  
  def self.post_activity(con, data)
    OpenSocial::PostActivityRequest.new(con).send(data)
  end
  
  def self.post_appdata(con, data)
    OpenSocial::PostAppDataRequest.new(con).send(data)
  end
end
