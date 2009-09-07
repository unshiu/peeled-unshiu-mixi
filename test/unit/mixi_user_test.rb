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
  
  define_method('test: mixi_friends はmixi友達関連を取得する') do 
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
  
  define_method('test: count_owner は実際にガジェットをインストールしているユーザ数を取得する') do 
    
    # joined_at 日付が入っているのがガジェット保持者
    assert_difference("MixiUser.count_owner", 1) do
      mixi_user = MixiUser.create({"mixi_id" => "test_mixi_id_a", "nickname" => "nickname", "joined_at" => Time.now,
                                   "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
    end
    
    # joined_at 日付が入っているなければカウント数は増えない
    assert_difference("MixiUser.count_owner", 0) do
      mixi_user = MixiUser.create({"mixi_id" => "test_mixi_id_b", "nickname" => "nickname",
                                   "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
    end
  end
  
  define_method('test: create_or_update はmixiユーザを作成する') do 
    mixi_user = MixiUser.create_or_update({"mixi_id" => "test_mixi_id", "nickname" => "nickname", 
                                           "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
    assert_not_nil(mixi_user)
    assert_equal(mixi_user.mixi_id, "test_mixi_id")
    assert_equal(mixi_user.status, 1) # 有効
  end
  
  define_method('test: create_or_update はmixiユーザを更新する') do 
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
  
  define_method('test: create_or_update は名前が空であったらmixiユーザを作成をしない') do 
    mixi_user = MixiUser.create_or_update({"mixi_id" => "empty_test_mixi_id", "nickname" => "", 
                                           "profile_url" => "", "thumbnail_url" => ""})
    assert_nil(mixi_user) # 作成されないのでnilがかえる
    
    mixi_user = MixiUser.find_by_mixi_id("empty_test_mixi_id")
    assert_nil(mixi_user)
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
  
  define_method('test: mixiユーザを作成するとbase_userも自動的に作成される') do 
    mixi_user = MixiUser.create_or_update({"mixi_id" => "test_my_mixi_id", "nickname" => "nickname", 
                                           "profile_url" => "http://hoge", "thumbnail_url" => "http://hoge"})
    assert_not_nil(mixi_user.base_user)
    assert_equal(mixi_user.base_user.status, 2) # 有効なユーザステータス
  end
end