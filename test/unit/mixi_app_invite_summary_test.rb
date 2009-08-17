require File.dirname(__FILE__) + '/../test_helper'

module MixiAppInviteSummaryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_app_invites
      end
    end
  end
  
  define_method('test: mixi_app_invite_summary の関連') do
  end
  
end