#
# ユーザ登録処理処理：
# リアルタイムで処理する必要がない以下のような処理をバックグラウンドで行う
#  友人関係の逆のリレーション
#  一度登録された友人関係がなくなっている場合の対応
#   削除する際はデータの性質上、レコード数が増えることが懸念されかつ、過去データの保持をアプリ側でする意味がないので物理削除する
#
module MixiUserRegistWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :mixi_user_regist_worker
      end
    end
  end
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    MixiFriend.new # 宣言しないとbackgroundがMixiFriendをloadできなといわれおちてしまう
  end
  
  def mixi_user_regist(request)
    mixi_user = request[:mixi_user]
    mixi_user_friends = request[:mixi_friends]
    
    mixi_user_friends.each do | mixi_user_friend |
      mixi_user_friend.mixi_friends << mixi_user unless mixi_user_friend.mixi_friends.member?(mixi_user)
    end
    
    friend_ids = mixi_user_friends.collect { |mixi_user_friend| mixi_user_friend.id }
    mixi_user = MixiUser.find(mixi_user.id)
    mixi_friendships = mixi_user.mixi_friendships
    mixi_friendships = mixi_friendships.delete_if { |mixi_friendship| friend_ids.member?(mixi_friendship.friend_id) }
    
    mixi_friendships.each do |mixi_friendship|
      mixi_friendship.destroy! 
    end
  end
  
  def mixi_friends_register(args)
    viewer = MixiUser.first(:conditions => { :mixi_id => args[:viewer_id] })
    rest_handler = args[:rest_handler]
    offset = 0
    limit = AppResources[:mixi][:friends_api_count]
    friend_ids = []
    loop do
      params = { 'startIndex' => offset, 'count' => limit }
      results = rest_handler.people('@me', '@friends', params)
      friends = results.values.map do |r|
        {
          'mixi_id' => r['id'].split(':').last,
          'nickname' => r['display_name'],
          'thumbnail_url' => r['thumbnail_url']
        }
      end
      friend_ids += friends.map {|friend| friend['mixi_id'] }
      register_friends(viewer, friends)
      break if results.size != limit
      offset += limit
    end
    
    friend_users = MixiUser.find(:all, :conditions => ['mixi_id in (?)', friend_ids])
    create_reverse_relation(viewer, friend_users)
    delete_old_relation(viewer, friend_users)
  end
  
  def register_friends(user, friends)
    friends.each do |friend|
      friend_user = MixiUser.create_or_update(friend)
      user.mixi_friends << friend_user unless user.mixi_friends.member?(friend_user)
    end
  end
  
  def create_reverse_relation(mixi_user, friend_mixi_users)
    friend_mixi_users.each do |friend|
      friend.mixi_friends << mixi_user unless friend.mixi_friends.member?(mixi_user)
    end
  end
  
  def delete_old_relation(mixi_user, friend_mixi_users)
    friend_ids = friend_mixi_users.map {|friend| friend.id }
    mixi_friendships = mixi_user.mixi_friendships
    mixi_friendships = mixi_friendships.delete_if do |mixi_friendship|
      friend_ids.member?(mixi_friendship.friend_id)
    end
    mixi_friendships.each do |mixi_friendship|
      mixi_friendship.destroy!
    end
  end
end