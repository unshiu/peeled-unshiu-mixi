
class MixiApplicationController
  include MixiApplicationControllerModule
  
  def signature_require
    return true
  end
end

module MixiApplicationControllerTestModule

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
  
  define_method('test: remote_token は認証用のtokenを発行する') do
      
    post :remote_token
    assert_response :success
    
  end
end