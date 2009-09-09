module MixiPoncansControllerTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :mixi_users
        fixtures :pnt_points
        fixtures :pnt_histories
      end
    end
  end

  define_method('test: receipt は成果通知を受け取りポイント処理を実行する') do 
    PntHistory.delete_all # 結果確認に邪魔なので消しておく
    
    @request.remote_addr = "127.0.0.1" # テスト環境ではこのアドレスのみ許す
    
    post :receipt, :uid => 1, :rid => 2, :point => 100, :cash => 100, :status => 1
    assert_response :success
    assert_template :text => "1"
    
    pnt_point = PntPoint.find_by_base_user_id(1)
    assert_equal(pnt_point.point, 200)

    history = PntHistory.find(:first, :conditions => ['pnt_point_id = ? ', pnt_point.id])
    assert_not_nil history
    assert_equal(history.difference, 100)
    assert_equal(history.amount, 200)
  end
  
  define_method('test: receipt は成果通知をリクエスト元がponcanサーバでない場合処理しない') do 
    PntHistory.delete_all # 結果確認に邪魔なので消しておく
    
    @request.remote_addr = "127.0.0.2"
    
    post :receipt, :uid => 1, :rid => 2, :point => 100, :cash => 100, :status => 1
    assert_redirect_with_error_code "U-10001"
    
    pnt_point = PntPoint.find_by_base_user_id(1)
    assert_equal(pnt_point.point, 100)

    history = PntHistory.find(:first, :conditions => ['pnt_point_id = ? ', pnt_point.id])
    assert_nil history
  end
end