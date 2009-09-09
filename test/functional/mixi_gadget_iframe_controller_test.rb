class MixiGadgetIframeController
  include MixiGadgetIframeControllerModule
  
  def signature_require
    return true
  end
end

module MixiGadgetIframeControllerTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::GadgetControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_tokens
      end
    end
  end
  
  define_method('test: remote_token は認証用のtokenを発行する') do
    post :remote_token
    assert_response :success
    
    assert_not_nil(assigns["mixi_token"])
  end
  
  define_method('test: index は外部から直接開かれるのをさけるためにtokenを渡さないと閲覧できない') do 
    post :index
    assert_response :redirect
    assert_redirect_with_error_code "U-10000"
  end
  
  define_method('test: index は発行されたtokenを渡せば閲覧できる') do 
    mixi_token = mixi_tokens(:secret_token)
    
    post :index, :mixi_token => mixi_token.token
    #assert_response :success assertするとそのせいで複数回リクエストが行われうまくうごかないので
    #assert_template "index"
    
    mixi_token = MixiToken.find(mixi_token.id)
    assert_equal(mixi_token.use_flag, true) # 使用済み
  end
  
  define_method('test: index は既に利用されたtokenは再利用できない') do 
    mixi_token = mixi_tokens(:use_token)
    
    post :index, :mixi_token => mixi_token.token
    assert_response :redirect
    assert_redirect_with_error_code "U-10000"
  end
end