require File.dirname(__FILE__) + '/../test_helper'
require "benchmark"

module MixiLatestLoginTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_app_invites
      end
    end
  end
  
  define_method('test: 最終ログイン日を更新する') do
    mixi_latest_login = MixiLatestLogin.update_latest_login(1)
    p mixi_latest_login
    assert_not_nil(mixi_latest_login.latest_login) # 最終日付がある
  end
  
  define_method('test: キャッシュされた最終ログイン日を取得する') do
    mixi_latest_login = MixiLatestLogin.find_by_mixi_user_id(1)
    assert_not_nil(mixi_latest_login.latest_login) # 最終日付がある
  end
  
  define_method('test: 最終ログイン日がない場合はnilオブジェクトがかえる') do
    mixi_latest_login = MixiLatestLogin.find_by_mixi_user_id(999)
    assert_nil(mixi_latest_login)
  end
  
  define_method('test: 最終ログイン日が１ヶ月以内のユーザ検索') do
    puts Benchmark::CAPTION
    #puts Benchmark.measure{
    #  assert_not_nil(MixiLatestLogin.count(:conditions => ["latest_login > ?", Time.now - 1.months]))
    #}
  end
  
end