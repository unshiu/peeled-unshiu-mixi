require File.dirname(__FILE__) + '/../test_helper'

module MixiUserTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_app_invites
      end
    end
  end
  
  define_method('test: mixi友達関連を取得する') do 
    mixi_user = MixiUser.find(1)
    assert_not_nil(mixi_user)
    assert_not_nil(mixi_user.mixi_friends)
    
    mixi_user = MixiUser.create_or_update({"mixi_id" => "test_mixi_id", "nickname" => "nickname", 
                                           "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
                                           
    assert_difference("MixiUser.find(1).mixi_friends.size", 1) do
      mixi_friend = MixiFriend.new
      mixi_friend.mixi_user_id = 1
      mixi_friend.friend_id = mixi_user.id
      mixi_friend.save
    end
  end
  
  define_method('test: mixiユーザを作成する') do 
    mixi_user = MixiUser.create_or_update({"mixi_id" => "test_mixi_id", "nickname" => "nickname", 
                                           "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
    assert_not_nil(mixi_user)
    assert_equal(mixi_user.mixi_id, "test_mixi_id")
    assert_equal(mixi_user.status, 1) # 有効
  end
  
  define_method('test: mixiユーザを更新する') do 
    mixi_user = MixiUser.create_or_update({"mixi_id" => "test_mixi_id", "nickname" => "nickname", 
                                           "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
    assert_not_nil(mixi_user)
    assert_equal(mixi_user.mixi_id, "test_mixi_id")
    assert_equal(mixi_user.nickname, "nickname")
    
    user_count = MixiUser.count
    
    mixi_user = MixiUser.create_or_update({"mixi_id" => "test_mixi_id", "nickname" => "nickname2", 
                                           "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
    
    assert_not_nil(mixi_user)
    assert_equal(mixi_user.mixi_id, "test_mixi_id")
    assert_equal(mixi_user.nickname, "nickname2")
    
    assert_equal(user_count, MixiUser.count) # 更新されているのでユーザは増えていない
  end
  
  define_method('test: mixiユーザの友達関連を保持できる') do 
    my_mixi_user = MixiUser.create_or_update({"mixi_id" => "test_my_mixi_id", "nickname" => "nickname", 
                                              "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
    friend_mixi_user = MixiUser.create_or_update({"mixi_id" => "test_friend_mixi_id", "nickname" => "nickname", 
                                                  "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
                                                  
    my_mixi_user.mixi_friends << friend_mixi_user
    my_mixi_user.save
    
    mixi_friend = MixiFriend.find_by_mixi_user_id(my_mixi_user.id)
    assert_not_nil(mixi_friend)
    assert_equal(mixi_friend.mixi_user_id, my_mixi_user.id)
    assert_equal(mixi_friend.friend_id, friend_mixi_user.id)
  end
end