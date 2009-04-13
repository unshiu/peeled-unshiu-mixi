require File.dirname(__FILE__) + '/../test_helper'

module MixiFriendTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_app_invites
      end
    end
  end
  
  define_method('test: mixi_userとの関連をもつ') do 
    assert_equal(MixiFriend.find(1).bemixi_friend_shipped, MixiUser.find(1))
    assert_equal(MixiFriend.find(1).mixi_friend_shipped, MixiUser.find(2))
  end
  
end