require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../../../vendor/plugins/mixi/test/unit/lib/worker/mixi_active_history_create_worker_test.rb'
require "#{RAILS_ROOT}/lib/workers/mixi_active_history_create_worker"

class MixiActiveHistoryCreateWorkerTest < ActiveSupport::TestCase
  include MixiActiveHistoryCreateWorkerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end