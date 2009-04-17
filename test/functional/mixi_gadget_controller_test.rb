module MixiGadgetControllerTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::GadgetControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :mixi_users
        fixtures :mixi_friends
      end
    end
  end

  define_method('test: gadget.xmlを表示する') do 
    
    post :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(session[:valid])
  end
  
  define_method('test: コンテナから取得したユーザ情報と友達情報を登録する-初期登録の場合') do 
    session[:valid] = true
    
    owner = { "mixi_id" => 500, "nickname" => "jane", 
                              "profile_url" => "http://unshiu.drecom.jp/profile/500",
                              "thumbnail_url" => "http://unshiu.drecom.jp/profile/500/profile.gif" }.to_json
    friends = [ { "mixi_id" => 501, "nickname" => "doe", 
                                  "profile_url" => "http://unshiu.drecom.jp/profile/501",
                                  "thumbnail_url" => "http://unshiu.drecom.jp/profile/501/profile.gif" } ].to_json
    
    post :register, :owner => owner, :friends => friends
    assert_response :redirect
    assert_redirected_to :action => 'top'
    
    mixi_user = MixiUser.find_by_mixi_id(500)
    assert_equal(mixi_user.nickname, "jane")
    assert_equal(mixi_user.profile_url, "http://unshiu.drecom.jp/profile/500")
    assert_equal(mixi_user.thumbnail_url, "http://unshiu.drecom.jp/profile/500/profile.gif")
    assert_not_nil(mixi_user.joined_at) # アプリ利用者なのでアプリを利用している
    
    mixi_user = MixiUser.find_by_mixi_id(501)
    assert_equal(mixi_user.nickname, "doe")
    assert_equal(mixi_user.profile_url, "http://unshiu.drecom.jp/profile/501")
    assert_equal(mixi_user.thumbnail_url, "http://unshiu.drecom.jp/profile/501/profile.gif")
    
  end
  
  define_method('test: コンテナから取得したユーザ情報と友達情報を登録する-既存データがある場合') do 
    session[:valid] = true
    
    owner = { "mixi_id" => 1, "nickname" => "jane", 
                              "profile_url" => "http://unshiu.drecom.jp/profile/1",
                              "thumbnail_url" => "http://unshiu.drecom.jp/profile/1/profile.gif" }.to_json
    friends = [ { "mixi_id" => 2, "nickname" => "doe", 
                                  "profile_url" => "http://unshiu.drecom.jp/profile/2",
                                  "thumbnail_url" => "http://unshiu.drecom.jp/profile/2/profile.gif" },
                { "mixi_id" => 999, "nickname" => "new_user", 
                                    "profile_url" => "http://unshiu.drecom.jp/profile/999",
                                    "thumbnail_url" => "http://unshiu.drecom.jp/profile/999/profile.gif" } ].to_json
    
    post :register, :owner => owner, :friends => friends
    assert_response :redirect
    assert_redirected_to :action => 'top'
    
    mixi_user = MixiUser.find_by_mixi_id(1)
    assert_equal(mixi_user.nickname, "jane")
    assert_equal(mixi_user.profile_url, "http://unshiu.drecom.jp/profile/1")
    assert_equal(mixi_user.thumbnail_url, "http://unshiu.drecom.jp/profile/1/profile.gif")
    assert_not_nil(mixi_user.joined_at) # アプリ利用者なのでアプリを利用している
    
    mixi_user = MixiUser.find_by_mixi_id(2)
    assert_equal(mixi_user.nickname, "doe")
    assert_equal(mixi_user.profile_url, "http://unshiu.drecom.jp/profile/2")
    assert_equal(mixi_user.thumbnail_url, "http://unshiu.drecom.jp/profile/2/profile.gif")
    
    # 今回新規に登録されたユーザ
    mixi_user = MixiUser.find_by_mixi_id(999)
    assert_equal(mixi_user.nickname, "new_user")
    assert_equal(mixi_user.profile_url, "http://unshiu.drecom.jp/profile/999")
    assert_equal(mixi_user.thumbnail_url, "http://unshiu.drecom.jp/profile/999/profile.gif")
    assert_nil(mixi_user.joined_at) # 今回はじめて登録された＝アプリを利用していない
  end
  
  define_method('test: 有効なセッションではないのでtimout画面を表示する') do 
    session[:valid] = false
    
    post :register
    assert_response :success
    assert_template 'timeout'
  end
end