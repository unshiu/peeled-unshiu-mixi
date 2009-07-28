require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mixi/test/functional/mixi_application_controller_test.rb'

class MixiApplicationControllerTest < ActionController::TestCase
  include MixiApplicationControllerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
