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
  
end