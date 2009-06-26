require File.dirname(__FILE__) + '/../../test_helper'

class Manage::MixiAppsControllerTest < ActionController::TestCase
  include TestUtil::Base::PcControllerTest
  fixtures :base_users
  fixtures :base_user_roles
  fixtures :mixi_apps
  
  define_method('test: mixiアプリ一覧を表示する') do
    login_as :quentin
    
    get :index
    assert_response :success
    assert_template "index"
    
    assert_not_nil(assigns["mixi_apps"])
  end
  
  define_method('test: mixiアプリを作成画面を表示する') do
    login_as :quentin
    
    get :new
    assert_response :success
    assert_template "new"
    
    assert_not_nil(assigns["mixi_app"])
  end
  
  define_method('test: mixiアプリを作成確認画面を表示する') do
    login_as :quentin
    
    post :create_confirm, :mixi_app => {:name => "test"}
    assert_response :success
    assert_template "create_confirm"
    
    assert_not_nil(assigns["mixi_app"])
  end
  
  define_method('test: mixiアプリを作成確認画面を表示しようとするが必須項目が空なので入力画面へ戻る') do
    login_as :quentin
    
    post :create_confirm, :mixi_app => {:name => ""}
    assert_response :success
    assert_template "new"
    
    assert_not_nil(assigns["mixi_app"])
  end
  
  define_method('test: mixiアプリを作成実行をする') do
    login_as :quentin
    
    post :create, :mixi_app => {:name => "test_create", :key => "hoge"}
    assert_response :redirect
    assert_redirected_to :action => :index
    
    mixi_app = MixiApp.find_by_name('test_create')
    assert_not_nil(mixi_app)
    assert_not_nil(mixi_app.key) # keyも生成済み
  end
  
  define_method('test: mixiアプリを作成実行のキャンセルをする') do
    login_as :quentin
    
    post :create, :mixi_app => {:name => "test_cancel_create", :key => "hoge"}, :cancel => 'true'
    assert_response :success
    assert_template "new"
    
    mixi_app = MixiApp.find_by_name('test_cancel_create')
    assert_nil(mixi_app) # キャンセルしたいので作成されていない
  end
  
  define_method('test: mixiアプリ個別詳細を表示する') do
    login_as :quentin
    
    get :show, :id => 1
    assert_response :success
    assert_template "show"
    
    assert_not_nil(assigns["mixi_app"])
  end
end
