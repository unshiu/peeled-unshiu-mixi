require File.dirname(__FILE__) + '/../test_helper'

module MixiPoncanTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
      end
    end
  end
  
  define_method('test: MixiPoncan は poncanからの成果通知ping情報を元にオブジェクトをつくる') do
    result_ping = {:uid => 1, :rid => 2, :cash => 100, :point => 200, :status => 1}
    poncan = MixiPoncan.new(result_ping)
    
    assert_equal(poncan.uid, 1)
    assert_equal(poncan.rid, 2)
    assert_equal(poncan.cash, 100)
    assert_equal(poncan.point, 200)
    assert_equal(poncan.status, 1)
  end
end