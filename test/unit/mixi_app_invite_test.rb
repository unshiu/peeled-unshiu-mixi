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
  
  define_method('test: installed は招待してかつ登録したユーザをかえす') do
    assert_difference "MixiAppInvite.installed.count", 1 do
      # invite_status が　2 なら登録済み
      MixiAppInvite.create({:mixi_user_id => 1, :invitee_user_id => 2, :invite_status => 2})
    end
    
    # invite_status が　2 以外なら登録には至っていない
    assert_difference "MixiAppInvite.installed.count", 0 do
      MixiAppInvite.create({:mixi_user_id => 1, :invitee_user_id => 2, :invite_status => 1})
    end
  end
  
  define_method('test: invited_create は招待した情報を作成する') do
    mixi_app_invite = MixiAppInvite.invited_create({:mixi_user_id => 1, :invitee_user_id => 2})
    assert_equal(mixi_app_invite.invite_status, 1) # ステータスは招待済み
  end
  
end