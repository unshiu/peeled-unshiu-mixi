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
  
  define_method('test: 前日のアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    assert_difference 'MixiActiveHistory.count', 1 do 
      worker = MixiActiveHistoryCreateWorker.new
      worker.update_yesterday_active_count
    end
    
    history = MixiActiveHistory.find(:first, :conditions => ['history_day = ?', Date.today - 1])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
  
  define_method('test: 過去7日以内にログインしたアクティブユーザ数を計算し、履歴テーブルを更新する') do 
    
    target_day = Date.today - 7
    assert_difference 'MixiActiveHistory.count', 1 do 
      worker = MixiActiveHistoryCreateWorker.new
      worker.update_active_count_by_day(Date.today, target_day) 
    end
    
    history = MixiActiveHistory.find(:first, :conditions => ['history_day = ?', Date.today])
    assert_not_nil(history)
    assert_not_nil(history.user_count)
  end
  
end