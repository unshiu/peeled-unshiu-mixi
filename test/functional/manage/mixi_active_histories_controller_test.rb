
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

  define_method('test: アクティブユーザ数履歴を表示する') do 
    login_as :quentin
    
    get :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_not_nil(assigns['years'])
  end
  
  define_method('test: 年度別アクティブユーザ数履歴を表示する') do 
    login_as :quentin
    
    get :index, :year => 2009
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_not_nil(assigns['years'])
    assert_not_equal(assigns['mixi_active_histories'].size, 0)
    
    get :index, :year => 3009
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_equal(assigns['mixi_active_histories'].size, 0) # 3009 の履歴はない
    
  end
  
  define_method('test: 月別アクティブ数履歴を表示する') do 
    login_as :quentin
    
    get :month
    assert_response :success
    assert_template 'month'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_not_nil(assigns['years'])
    assert_not_equal(assigns['mixi_active_histories'].size, 0)    
  end
  
  define_method('test: 年度別月別アクティブ数履歴を表示する') do 
    login_as :quentin
    
    get :month, :year => 2009
    assert_response :success
    assert_template 'month'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_not_nil(assigns['years'])
    assert_not_equal(assigns['mixi_active_histories'].size, 0)
    
    get :month, :year => 3009
    assert_response :success
    assert_template 'month'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_equal(assigns['mixi_active_histories'].size, 0) # 3009 の履歴はない   
  end
  
  define_method('test: 年度別アクティブ数履歴を表示する') do 
    login_as :quentin
    
    get :year
    assert_response :success
    assert_template 'year'
    
    assert_not_nil(assigns['mixi_active_histories'])
    assert_not_equal(assigns['mixi_active_histories'].size, 0)    
  end
  
  define_method('test: 日別のアクティブユーザ数を表示する') do 
    login_as :quentin
  
    post :search, :mixi_user_active_seach => { 
                               :type => { "day" => true}, 
                               "start_at(1i)" => 2008, "start_at(2i)" => 2, "start_at(3i)" => 12,
                               "end_at(1i)"   => 2010, "end_at(2i)"   => 10, "end_at(3i)"   => 10}
    assert_response :success
    assert_template 'search'
  end
  
  define_method('test: 月別のアクティブユーザ数を表示する') do 
    login_as :quentin
  
    post :search, :mixi_user_active_seach => { 
                              :type     => { "month" => true}, 
                              "start_at(1i)" => 2008, "start_at(2i)" => 2, "start_at(3i)" => 12,
                               "end_at(1i)"   => 2010, "end_at(2i)"   => 10, "end_at(3i)"   => 10}
    assert_response :success
    assert_template 'search'
  end
  
end