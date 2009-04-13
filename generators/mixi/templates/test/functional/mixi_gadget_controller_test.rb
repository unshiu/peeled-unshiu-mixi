require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mixi/test/functional/mixi_gadget_controller_test.rb'

class MixiGadgetControllerTest < ActionController::TestCase
  include MixiGadgetControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
