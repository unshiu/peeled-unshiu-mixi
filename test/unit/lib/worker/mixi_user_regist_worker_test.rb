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
  
  define_method('test: mixi_friends_register はREST APIで取得した友人の情報をDBに保存する') do
    mixi_id = 'test_mixi_id'
    mixi_user = MixiUser.create({:mixi_id => mixi_id, :nickname => 'test_mixi_id'})
    
    friends_data = { '1' => { 'id' => '1',
                              'display_name' => 'mixi_user_id_1',
                              'thumbnail_url' => 'http://example.com/thumbnail/user_id_1' }}
    MixiAPI::RESTHandler.any_instance.stubs(:people).returns(friends_data)
    rest_handler = MixiAPI::RESTHandler.new(mixi_id)
    
    worker = MixiUserRegistWorker.new
    worker.mixi_friends_register({:viewer_id => mixi_id, :rest_handler => rest_handler})
    
    assert(mixi_user.mixi_friends.member?(MixiUser.find(1)))
  end
  
  define_method('test: create_reverse_relation は逆方向の友人関係をDBに保存する') do
    new_mixi_user = MixiUser.create({:mixi_id => 'test_mixi_id', :nickname => 'test_mixi_id'})
    mixi_user = MixiUser.find(1)
    new_mixi_user.mixi_friends << mixi_user
    
    assert(!mixi_user.mixi_friends.member?(new_mixi_user)) # 逆向きの友人関係がまだ存在しない
    
    worker = MixiUserRegistWorker.new
    worker.create_reverse_relation(new_mixi_user, [ mixi_user ])
    
    assert(mixi_user.mixi_friends.member?(new_mixi_user)) # 逆向きの友人関係が作成された
  end
  
  define_method('test: delete_old_relation は友達関係がなくなっていたらDBに反映する') do
    new_mixi_user = MixiUser.create({:mixi_id => 'test_mixi_id', :nickname => 'test_mixi_id'})
    mixi_user_1 = MixiUser.find(1)
    mixi_user_2 = MixiUser.find(2)
    new_mixi_user.mixi_friends << mixi_user_1
    new_mixi_user.mixi_friends << mixi_user_2
    
    assert(new_mixi_user.mixi_friends.member?(mixi_user_1))
    assert(new_mixi_user.mixi_friends.member?(mixi_user_2))
    
    worker = MixiUserRegistWorker.new
    worker.delete_old_relation(new_mixi_user, [ mixi_user_1 ])
    
    new_mixi_user.reload
    assert(new_mixi_user.mixi_friends.member?(mixi_user_1))   # 友人関係が保持されている
    assert(!new_mixi_user.mixi_friends.member?(mixi_user_2))  # 友人関係が削除されている
  end
end