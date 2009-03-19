require File.dirname(__FILE__) + '/../test_helper'

module MixiAppTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_apps
        fixtures :mixi_users
        fixtures :mixi_app_regists
        fixtures :mixi_app_invites
      end
    end
  end
  
  define_method('test: ランダムな英数字であるkeyを生成する') do 
    mixi_app = MixiApp.new
    mixi_app.key_generate
    assert_not_nil(mixi_app.key)
    assert_equal(mixi_app.key.length, 32)
  end
  
  define_method('test: 特定のアプリをインストールしているユーザ数をかえす') do 
    mixi_app = MixiApp.find(1)
    
    before_count = mixi_app.mixi_users.count
    
    regist = MixiAppRegist.new
    regist.mixi_app_id = 1
    regist.mixi_user_id = 2
    regist.save
    
    assert_equal before_count + 1, mixi_app.mixi_users.count
  end
  
  define_method('test: 特定のアプリをインストール後削除しているユーザ数をかえす') do 
    mixi_app = MixiApp.find(1)
    
    before_count = mixi_app.count_delete_mixi_users
    
    regist = MixiAppRegist.new
    regist.mixi_app_id = 1
    regist.mixi_user_id = 2
    regist.deleted_at = Time.now
    regist.save # 解除ユーザを増やす
    
    assert_equal before_count + 1, mixi_app.count_delete_mixi_users
  end
  
  define_method('test: 1ユーザの平均配布数を取得する') do 
    mixi_app = MixiApp.find(1)
    
    before_avg = mixi_app.avg_invite_per_user
    
    invite = MixiAppInvite.new({:mixi_app_id => 1, :mixi_user_id => 2, :invitee_user_id => 1})
    invite.save 
    
    invite = MixiAppInvite.new({:mixi_app_id => 1, :mixi_user_id => 2, :invitee_user_id => 3})
    invite.save 
    
    assert_equal mixi_app.avg_invite_per_user, 2.0
    
    invite = MixiAppInvite.new({:mixi_app_id => 1, :mixi_user_id => 1, :invitee_user_id => 4})
    invite.save 
    
    assert_equal mixi_app.avg_invite_per_user, 1.5
  end
  
end
