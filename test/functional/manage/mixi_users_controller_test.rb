
module Manage::MixiUsersControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_profiles
        fixtures :mixi_users
        fixtures :mixi_friends
      end
    end
  end

  define_method('test: mixiアプリ管理トップを表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns['mixi_user_count'])
    assert_not_nil(assigns['mixi_delete_user_count'])
    assert_not_nil(assigns['mixi_avg_invite_per_user'])
  end
  
end