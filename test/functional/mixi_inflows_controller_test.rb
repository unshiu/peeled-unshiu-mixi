
module MixiInflowsControllerTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::GadgetControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_inflows
        fixtures :mixi_inflow_masters
      end
    end
  end

  define_method('test: add はkeyを渡されないとその他からアクセスしたユーザに痕跡としてcookieを付加する') do 
    
    assert_difference "MixiInflow.count(:conditions => ['mixi_inflow_master_id = ? ', MixiInflowMaster::OTHER])", 1 do
      post :add
    end
    
    assert_response :success
    assert_template 'add'
    
    assert_not_nil(assigns["unique_key"])
  end
  
  define_method('test: add はkeyを渡されるとそのkeyから流入元を設定する') do 
    
    blog_inflow_master = mixi_inflow_masters(:blog)
    assert_difference "MixiInflow.count(:conditions => ['mixi_inflow_master_id = ? ', blog_inflow_master.id])", 1 do
      post :add, :key => blog_inflow_master.route_key
    end
    
    assert_response :success
    assert_template 'add'
    
    assert_not_nil(assigns["unique_key"])
  end
  
  define_method('test: add はnext_urlを渡されるとcookieを設定した後のとび先を変更できる') do 
    
    blog_inflow_master = mixi_inflow_masters(:blog)
    assert_difference "MixiInflow.count(:conditions => ['mixi_inflow_master_id = ? ', blog_inflow_master.id])", 1 do
      post :add, :key => blog_inflow_master.route_key, :next_url => "http://next"
    end
    
    assert_response :success
    assert_template 'add'
    
    assert_not_nil(assigns["unique_key"])
    assert_equal(assigns["next_url"], "http://next")
  end
  
  define_method('test: show はmixiアプリ側で表示処理をしcookieを取得する') do 
    
    post :show, :mixi_user_id => 1, :app_name => "unshiu"
    assert_response :success
    assert_template 'show'
    
    assert_equal(assigns["mixi_user_id"], "1")
    assert_equal(assigns["app_name"], "unshiu")
  end
  
  define_method('test: create はアプリを登録したと記録する') do 
    
    post :create, :mixi_user_id => 1, :app_name => "unshiu", :tracking_key => "tracking_key_test_a"
    assert_response :success
    assert_template '' # remote_function から呼び出されるので基本何もかえさない
    
    inflow = MixiInflow.find_by_tracking_key("tracking_key_test_a")
    assert_not_nil(inflow.registed_at)
    assert_not_nil(inflow.app_name)
  end
end