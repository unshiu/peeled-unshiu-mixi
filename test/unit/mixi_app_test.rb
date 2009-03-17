require File.dirname(__FILE__) + '/../test_helper'

module MixiAppTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_apps
        fixtures :mixi_users
        fixtures :mixi_app_regists
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
    
    mixi_app = MixiApp.find(1)
    assert_equal before_count + 1, mixi_app.mixi_users.size
  end
  
end
