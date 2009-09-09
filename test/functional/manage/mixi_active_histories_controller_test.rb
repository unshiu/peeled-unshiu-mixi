
module Manage::MixiActiveHistoriesControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mixi_active_histories
      end
    end
  end

  define_method('test: index はアクティブユーザ数履歴を表示する') do 
    login_as :quentin
    
    get :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns['mixi_active_histories'])
  end
  
  define_method('test: index は指定された日付間のアクティブユーザ数履歴を表示する') do 
    login_as :quentin
    
    get :index, :id => 1
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_not_equal(assigns['mixi_active_histories'].size, 0)
    
    get :index, :id => 3
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_not_equal(assigns['mixi_active_histories'].size, 0)
    
  end
  
  define_method('test: 日別のアクティブユーザ数を表示する') do 
    login_as :quentin
  
    post :search, :mixi_user_active_seach => { 
                               :type => { "day" => true}, 
                               "start_at(1i)" => 2008, "start_at(2i)" => 1, "start_at(3i)" => 21 ,
                               "end_at(1i)"   => 2009,   "end_at(2i)" => 11,  "end_at(3i)" => 11 }
    assert_response :success
    assert_template 'search'
  end
  
  define_method('test: 月別のアクティブユーザ数を表示する') do 
    login_as :quentin
  
    post :search, :mixi_user_active_seach => { 
                              :type     => { "month" => true}, 
                              "start_at(1i)" => 2008, "start_at(2i)" => 2, "start_at(3i)" => 1,
                              "end_at(1i)"   => 2010, "end_at(2i)"   => 10, "end_at(3i)" => 30 } # 日情報はあげてもつかわない
    assert_response :success
    assert_template 'search'
  end
  
end