require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/mixi/test/unit/lib/worker/mixi_user_regist_worker_test.rb'
require "#{RAILS_ROOT}/lib/workers/mixi_user_regist_worker"

class MixiUserRegistWorkerTest < ActiveSupport::TestCase
  include MixiUserRegistWorkerTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end