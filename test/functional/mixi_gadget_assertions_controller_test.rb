class MixiGadgetAssertionsController < MixiApplicationController
  
  def redirect_to_path
    session[:opensocial_viewer] = MixiUser.find(1) # 実際にはfilterで追加されている
    redirect_mixi_gadget_to :action => 'index'
  end
end

module MixiGadgetAssertionsControllerTestModule

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
  
  define_method('test: redirect_mixi_gadget_to はgadget用のリダイレクト処理をする') do
    mixiapp_viewer = MixiUser.find(1)
    
    post :redirect_to_path
    assert_response :redirect
    
    # session_id と　viewer情報が自動的に付加される
    assert_redirected_to :action => 'index', :opensocial_viewer_id => mixiapp_viewer.id, AppResources[:init][:session_key] => "test_session"
  end
end