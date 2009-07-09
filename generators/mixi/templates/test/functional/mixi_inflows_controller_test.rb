require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mixi/test/functional/mixi_inflows_controller_test.rb'

class MixiInflowsControllerTest < ActionController::TestCase
  include MixiInflowsControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
end
