class MixiGadgetAssertionsController < MixiApplicationController
  
  def redirect_to_path
    @mixiapp_owner = MixiUser.find(1) # 実際にはfilterで追加されている
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
    @mixiapp_owner = MixiUser.find(1)
      
    post :redirect_to_path
    assert_response :redirect
    
    # session_id と　owner情報が自動的に付加される
    assert_redirected_to :action => 'index', :owner => @mixiapp_owner.id, AppResources[:init][:session_key] => "test_session"
  end
end