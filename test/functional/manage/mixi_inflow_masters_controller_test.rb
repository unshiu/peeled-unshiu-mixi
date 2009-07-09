module Manage::MixiInflowMastersControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mixi_users
        fixtures :mixi_inflows
        fixtures :mixi_inflow_masters
      end
    end
  end
  
  define_method('test: index は流入マスタ一覧を表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns["mixi_inflow_masters"])
  end
  
  define_method('test: show は流入マスタ詳細を表示する') do 
    login_as :quentin
    
    master = mixi_inflow_masters(:blog)
    
    post :show, :id => master.id
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns["mixi_inflow_master"])
  end
  
  define_method('test: create confirm は流入マスタを作成確認画面を表示する') do 
    login_as :quentin
    
    assert_difference 'MixiInflowMaster.count', 0 do
      post :create_confirm, :mixi_inflow_master => {:route_name => "test create"}
    end

    assert_response :success
    assert_template 'create_confirm'
  end
  
  define_method('test: create は流入マスタを作成する') do 
    login_as :quentin
    
    assert_difference 'MixiInflowMaster.count', 1 do
      post :create, :mixi_inflow_master => {:route_name => "test create", :route_key => "test create key"}
    end

    mixi_inflow_master = MixiInflowMaster.find_by_route_name("test create")
    assert_not_nil(mixi_inflow_master)
    assert_not_nil(mixi_inflow_master.route_key) # keyは自動作成されている
    
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => mixi_inflow_master.id
    
    assert_not_nil(assigns["mixi_inflow_master"])
  end
  
  define_method('test: edit は流入マスタ編集画面を表示する') do 
    login_as :quentin
    
    master = mixi_inflow_masters(:blog)
    
    post :edit, :id => master.id
    assert_response :success
    assert_template 'edit'
  end
  
  define_method('test: update confirm は流入マスタを作成確認画面を表示する') do 
    login_as :quentin
    
    master = mixi_inflow_masters(:blog)
    
    assert_difference 'MixiInflowMaster.count', 0 do
      post :update_confirm, :id => master.id, :mixi_inflow_master => {:route_name => "test create"}
    end

    assert_response :success
    assert_template 'update_confirm'
    
    mixi_inflow_master = MixiInflowMaster.find(master.id)
    assert_not_nil(mixi_inflow_master)
    assert_not_equal(mixi_inflow_master.route_name, "test update") # まだ更新されていない
  end
  
  define_method('test: update は流入マスタを編集する') do 
    login_as :quentin
    
    master = mixi_inflow_masters(:blog)
    
    assert_difference 'MixiInflowMaster.count', 0 do
      post :update, :id => master.id, :mixi_inflow_master => {:route_name => "test update"}
    end

    assert_response :redirect
    assert_redirected_to :action => 'show', :id => master.id
    
    assert_not_nil(assigns["mixi_inflow_master"])
    
    mixi_inflow_master = MixiInflowMaster.find(master.id)
    assert_not_nil(mixi_inflow_master)
    assert_equal(mixi_inflow_master.route_name, "test update")
  end
  
  define_method('test: destory_confirm は流入マスタを削除確認画面を表示する') do 
    login_as :quentin
    
    master = mixi_inflow_masters(:blog)
    
    post :destroy_confirm, :id => master.id
    
    assert_response :success
    assert_template 'destroy_confirm'
    
    mixi_inflow_master = MixiInflowMaster.find(master.id)
    assert_not_nil(mixi_inflow_master) # まだ削除されてない
  end
  
  define_method('test: destory は流入マスタを削除する') do 
    login_as :quentin
    
    master = mixi_inflow_masters(:blog)
    
    post :destroy, :id => master.id
    
    assert_response :redirect
    assert_redirected_to :action => 'index'
    
    mixi_inflow_master = MixiInflowMaster.find_by_id(master.id)
    assert_nil(mixi_inflow_master) # 削除済み
  end
end