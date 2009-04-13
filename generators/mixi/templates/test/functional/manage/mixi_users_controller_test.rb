require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../vendor/plugins/mixi/test/functional/manage/mixi_users_controller_test.rb'

class Manage::MixiUsersControllerTest < ActionController::TestCase
  include Manage::MixiUsersControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end