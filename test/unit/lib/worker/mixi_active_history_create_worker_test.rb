require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/mixi_active_history_create_worker"

module MixiActiveHistoryCreateWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_app_invites
        fixtures :mixi_active_histories
      end
    end
  end
  
  define_method('test: update_yesterday_active_count は前日のアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'MixiActiveHistory.count', 1 do 
      worker = MixiActiveHistoryCreateWorker.new
      worker.update_yesterday_active_count
    end
    
    history = MixiActiveHistory.find(:first, :conditions => ['before_days = 1'])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
    
    # TODO 本来は実際のアクティブユーザ数をカウントしチェックする必要があるがTokyoTyrantのデータであるためテストで再現ができないためとりあえずここまで
  end
  
  define_method('test: update_last_3days_active_count は過去3日以内にログインしたアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'MixiActiveHistory.count', 1 do 
      worker = MixiActiveHistoryCreateWorker.new
      worker.update_last_3days_active_count 
    end
    
    history = MixiActiveHistory.find(:first, :conditions => ['before_days = 3'])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
  
  define_method('test: update_last_week_active_count は過去7日以内にログインしたアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'MixiActiveHistory.count', 1 do 
      worker = MixiActiveHistoryCreateWorker.new
      worker.update_last_week_active_count 
    end
    
    history = MixiActiveHistory.find(:first, :conditions => ['before_days = 7'])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
  
  define_method('test: update_last_month_active_count は先月にログインしたアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'MixiActiveHistory.count', 1 do 
      worker = MixiActiveHistoryCreateWorker.new
      worker.update_last_month_active_count 
    end
    
    history = MixiActiveHistory.find(:first, :conditions => ['before_days = 30'])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
end