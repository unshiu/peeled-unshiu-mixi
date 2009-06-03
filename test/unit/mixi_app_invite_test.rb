require File.dirname(__FILE__) + '/../test_helper'

module MixiAppInviteTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_app_invites
      end
    end
  end
  
end