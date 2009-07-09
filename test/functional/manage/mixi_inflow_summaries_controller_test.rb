module Manage::MixiInflowSummariesControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mixi_users
        fixtures :mixi_inflows
        fixtures :mixi_inflow_masters
        fixtures :mixi_inflow_summaries
      end
    end
  end
  
  define_method('test: index は日別トータルの流入履歴を表示する') do 
    login_as :quentin
    
    post :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns["mixi_inflow_summaries"])
    
    assert(assigns["mixi_inflow_summaries"].size > 0)
    assigns["mixi_inflow_summaries"].each do |mixi_inflow_summary|
      assert_equal(mixi_inflow_summary.mixi_inflow_master_id, 1) # index はtotal履歴を表示するので
    end  
  end

  define_method('test: show は流入履歴詳細を表示する') do 
    login_as :quentin
    
    total_summary = mixi_inflow_summaries(:total)
    
    post :show, :id => total_summary.id
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns["mixi_inflow_summaries"])
    
    assert(assigns["mixi_inflow_summaries"].size > 0)
    assigns["mixi_inflow_summaries"].each do |mixi_inflow_summary|
      assert_equal(mixi_inflow_summary.start_at, total_summary.start_at) # 同日の個別履歴をすべて表示するので 
      assert_equal(mixi_inflow_summary.end_at, total_summary.end_at) 
    end  
  end
  
  define_method('test: search は流入履歴を検索する') do 
    login_as :quentin
    
    mixi_inflow_master = mixi_inflow_masters(:blog)
    
    post :search, :mixi_inflow_summary_search => { :mixi_inflow_master_id => mixi_inflow_master.id, 
                                                   "start_at(1i)" => 2008, "start_at(2i)" => 2,  "start_at(3i)" => 1,
                                                   "end_at(1i)"   => 2030, "end_at(2i)"   => 10, "end_at(3i)"   => 30,
                                                   :type => "day"}
    assert_response :success
    assert_template 'index'
    
    assert_not_nil(assigns["mixi_inflow_summaries"])
    
    assert(assigns["mixi_inflow_summaries"].size > 0)
    assigns["mixi_inflow_summaries"].each do |mixi_inflow_summary|
      assert_equal(mixi_inflow_summary.mixi_inflow_master_id, mixi_inflow_master.id)
    end  
  end
  
  define_method('test: search はtypeを指定すると月別の流入履歴を検索することもできる') do 
    login_as :quentin
    
    mixi_inflow_master = mixi_inflow_masters(:blog)
    
    post :search, :mixi_inflow_summary_search => { :mixi_inflow_master_id => mixi_inflow_master.id, 
                                                   "start_at(1i)" => 2008, "start_at(2i)" => 2,  "start_at(3i)" => 1,
                                                   "end_at(1i)"   => 2030, "end_at(2i)"   => 10, "end_at(3i)"   => 30,
                                                   :type => "month"}
    assert_response :success
    assert_template 'index'
  
    assert_not_nil(assigns["mixi_inflow_summaries"])
    
    assert(assigns["mixi_inflow_summaries"].size > 0)
    assigns["mixi_inflow_summaries"].each do |mixi_inflow_summary|
      assert_equal(mixi_inflow_summary.mixi_inflow_master_id, mixi_inflow_master.id)
      assert_equal(mixi_inflow_summary.summary_type, MixiInflowSummary::SUMMARY_MONTH)
    end  
  end
end