require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/mixi_user_regist_worker"

module MixiUserRegistWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_inflows
        fixtures :mixi_inflow_masters
        fixtures :mixi_inflow_summaries
      end
    end
  end
  
  define_method('test: mixi_user_regist はユーザ関連をDBへ保存する') do
    mixi_user = MixiUser.create({:mixi_id => "test_mixi_id", :nickname => "mixi_user_regist"})
    MixiFriend.create({:mixi_user_id => mixi_user.id, :friend_id => 1})
    mixi_user_friends = mixi_user.mixi_friends
    
    assert(!MixiUser.find(1).mixi_friends.member?(mixi_user)) # 逆方向の友人関係が保持されてない

    worker = MixiUserRegistWorker.new
    worker.mixi_user_regist({:mixi_user => mixi_user, :mixi_friends => mixi_user_friends})
    
    assert(MixiUser.find(1).mixi_friends.member?(mixi_user)) # 逆方向の友人関係が保持される
  end
  
  define_method('test: mixi_user_regist は与えられたユーザと既存のユーザを比較し友達関係のなくなっていたらDBに反映する') do
    mixi_user = MixiUser.find(1)
    create_mixi_user = MixiUser.create({:mixi_id => "test_mixi_id", :nickname => "mixi_user_regist"})
    MixiFriend.create({:mixi_user_id => 1, :friend_id => create_mixi_user.id})
    mixi_user_friends = [create_mixi_user]
    
    worker = MixiUserRegistWorker.new
    worker.mixi_user_regist(({:mixi_user => mixi_user, :mixi_friends => mixi_user_friends}))
    
    assert(!MixiUser.find(1).mixi_friends.member?(MixiUser.find(2))) # 友人関係が削除されている
    assert(MixiUser.find(1).mixi_friends.member?(create_mixi_user)) # 友人関係が保持されている
  end
end