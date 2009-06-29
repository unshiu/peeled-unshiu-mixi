require File.dirname(__FILE__) + '/../test_helper'

module MixiActivityTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_activities
      end
    end
  end
  
  define_method('test: mixi_userと関連を持つ') do 
    mixi_activity = MixiActivity.find(1)
    assert_not_nil(mixi_activity.create_mixi_user)  # 発信した人
    assert_not_nil(mixi_activity.receipt_mixi_user) # 受け取った人
  end
end
