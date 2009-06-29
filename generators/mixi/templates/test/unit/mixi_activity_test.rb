require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mixi/test/unit/mixi_activity_test.rb'

class MixiActivityTest < ActiveSupport::TestCase
  include MixiActivityTestModule
  
  test "baton_title はactivityタイトルを生成する" do
    title = MixiActivity.baton_title(MixiUser.find(1), Baton.find(1))
    assert_not_nil(title);
  end
  
end
