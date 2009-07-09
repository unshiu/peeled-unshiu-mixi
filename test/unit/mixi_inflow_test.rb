require File.dirname(__FILE__) + '/../test_helper'

module MixiInflowTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_inflows
        fixtures :mixi_inflow_masters
      end
    end
  end
  
  define_method('test: mixi_inflow の関連') do
    mixi_inflow = mixi_inflows(:registed)
    
    assert_not_nil(mixi_inflow.mixi_inflow_master)
    assert_not_nil(mixi_inflow.mixi_user)
  end
  
end