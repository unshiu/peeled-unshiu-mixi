require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mixi/test/unit/mixi_user_test.rb'

class MixiUserTest < ActiveSupport::TestCase
  include MixiUserTestModule
  
  fixtures :batons
  fixtures :baton_questions
  fixtures :baton_answers
  fixtures :baton_runners
  fixtures :mixi_users
  fixtures :mixi_friends
  
  test "recent_baton_answer_friend は最近バトンに答えたマイミクを指定数取得する" do
    
    user = MixiUser.create({:mixi_id => "555"})
    MixiFriend.create({:mixi_user_id => 1, :friend_id => user.id})
    BatonAnswer.create({:baton_question_id => 1, :mixi_user_id => user.id, :answer => "hoge"})
    
    assert_equal(MixiUser.find(1).recent_baton_answer_friend_with_paginate(2, 0).size, 2)
    assert_equal(MixiUser.find(1).recent_baton_answer_friend_with_paginate(3, 0).first.mixi_id, "555")
  end
  
  test "recent_answer_baton はそのユーザが最近答えたバトンをを取得する" do
    user = MixiUser.create({:mixi_id => 666})
    BatonAnswer.create({:baton_question_id => 1, :mixi_user_id => user.id, :answer => "hoge"})
    
    batons = MixiUser.find(user.id).recent_answer_baton(5)
    
    assert_not_nil(batons)
    assert_equal(batons[0].id, 1)
  end

  test "unanswer_friend はそのバトンを答えたことがないマイミクを取得する" do
    
    user = MixiUser.create({:mixi_id => "777"})
    MixiFriend.create({:mixi_user_id => 1, :friend_id => user.id})
    
    mixi_users = MixiUser.find(1).unanswer_baton_friend(1)
    
    assert_not_nil(mixi_users)
    assert_not_equal(mixi_users.size, 0)
    mixi_users.each do |mixi_user|
      assert_equal(mixi_user.mixi_id, "777")
    end
  end
  
end