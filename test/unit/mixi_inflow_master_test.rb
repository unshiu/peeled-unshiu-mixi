require File.dirname(__FILE__) + '/../test_helper'

module MixiInflowMasterTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_inflows
        fixtures :mixi_inflow_masters
      end
    end
  end
  
  define_method('test: mixi_inflow_master の関連') do
    mixi_inflow_master = mixi_inflow_masters(:blog)
    
    assert_not_nil(mixi_inflow_master.mixi_inflows)
  end
  
  define_method('test: inflow_mark_url は流入したことをチェックするためのURLを生成する') do
    mixi_inflow_master = mixi_inflow_masters(:blog)
    
    assert_equal(mixi_inflow_master.inflow_mark_url, "http://localhost:3000/mixi_inflows/add?key=?blog_key")
  end
  
end