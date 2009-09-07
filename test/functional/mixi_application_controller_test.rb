
class MixiApplicationController
  include MixiApplicationControllerModule
  
  def check_mixiapp_viewer
    @viewer = current_mixiapp_viewer
    render :text => "OK"
  end
  
  def check_mixiapp_owner
    @owner = current_mixiapp_owner
    render :text => "OK"
  end
  
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
  
  define_method('test: current_mixiapp_viewer は現在アプリを閲覧しているユーザ情報を取得する') do
    
    post :check_mixiapp_viewer, :opensocial_viewer_id => 1
    assert_response :success
    
    assert_equal(assigns["viewer"], MixiUser.find_by_mixi_id(1))
  end
  
  define_method('test: current_mixiapp_viewer はsessionにユーザ情報を持っていたらsession側を正とし、パラメータでわたってきても無視する') do
    
    session[:opensocial_viewer] = MixiUser.find_by_mixi_id(2)
    post :check_mixiapp_viewer, :opensocial_viewer_id => 1
    assert_response :success
    
    assert_equal(assigns["viewer"], MixiUser.find_by_mixi_id(2))
  end
  
  define_method('test: current_mixiapp_owner は現在アプリの所有者ユーザ情報を取得する') do
    
    post :check_mixiapp_owner, :opensocial_owner_id => 1
    assert_response :success
    
    assert_equal(assigns["owner"], MixiUser.find_by_mixi_id(1))
  end
  
  define_method('test: current_mixiapp_owner はsessionにユーザ情報を持っていたらsession側を正とし、パラメータでわたってきても無視する') do
    
    session[:opensocial_owner] = MixiUser.find_by_mixi_id(2)
    post :check_mixiapp_owner, :opensocial_owner_id => 1
    assert_response :success
    
    assert_equal(assigns["owner"], MixiUser.find_by_mixi_id(2))
  end
  
end