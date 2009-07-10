#
# ユーザ登録処理処理：
# リアルタイムで処理する必要がない以下のような処理をバックグラウンドで行う
#  友人関係の逆のリレーション
#  一度登録された友人関係がなくなっている場合の対応
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
  end
  
  def mixi_user_regist(request)
    mixi_user = request[:mixi_user]
    mixi_user_friends = request[:mixi_friends]
     
    mixi_user_friends.each do | mixi_user_friend |
      mixi_user_friend.mixi_friends << mixi_user unless mixi_user_friend.mixi_friends.member?(mixi_user)
    end
    
    friend_ids = mixi_user_friends.collect { |mixi_user_friend| mixi_user_friend.id }
    mixi_user = MixiUser.find(mixi_user.id)
    mixi_friend_ships = mixi_user.mixi_friend_ships
    mixi_friend_ships.delete_if { |mixi_friend_ship| friend_ids.member?(mixi_friend_ship.friend_id) }
    
    mixi_friend_ships.each do |mixi_friend_ship|
      mixi_friend_ship.destroy
    end
  end
  
end