require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/mixi_app_invite_summary_create_worker"

module MixiAppInviteSummaryCreateWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_app_invites
        fixtures :mixi_app_invite_summaries
      end
    end
  end

  define_method('test: update_yesterday は前日の招待数と広がり係数を履歴テーブルを更新する') do 
    MixiAppInvite.record_timestamps = false
    1.upto(100) do |i|
      invite_status = i % 2 == 0 ? 1 : 2
      MixiAppInvite.create({:mixi_user_id => 1, :invitee_user_id => i, :invite_status => invite_status,
                            :created_at => Time.now.yesterday, :updated_at => Time.now.yesterday})
    end
    MixiAppInvite.record_timestamps = true
    MixiActiveHistory.create(:history_day => Time.now.yesterday.to_date, :user_count => 200, :before_days => 1)
    
    assert_difference 'MixiAppInviteSummary.count', 1 do 
      worker = MixiAppInviteSummaryCreateWorker.new
      worker.update_yesterday
    end
    
    summary = MixiAppInviteSummary.find(:first, :conditions => ['summary_type = ?', MixiAppInviteSummary::SUMMARY_DAY])
    assert_not_nil(summary)
    assert_equal(summary.registed_mixi_user_count, 50) # 登録数
    assert_equal(summary.broadening_coefficient, 50/200.to_f) # 広がり係数=登録数/前日のアクティブUU
  end
  
  define_method('test: update_last_update は前週の招待数と広がり係数を履歴テーブルを更新する') do 
    MixiAppInvite.record_timestamps = false
    1.upto(100) do |i|
      invite_status = i % 2 == 0 ? 1 : 2
      MixiAppInvite.create({:mixi_user_id => 1, :invitee_user_id => i, :invite_status => invite_status,
                            :created_at => Time.now.ago(7.days).beginning_of_week, :updated_at => Time.now.ago(7.days).beginning_of_week})
    end
    MixiAppInvite.record_timestamps = true
    MixiActiveHistory.create(:history_day => Time.now.ago(7.days).beginning_of_week.to_date, :user_count => 500, :before_days => 7)
    
    assert_difference 'MixiAppInviteSummary.count', 1 do 
      worker = MixiAppInviteSummaryCreateWorker.new
      worker.update_last_week
    end
    
    summary = MixiAppInviteSummary.find(:first, :conditions => ['summary_type = ?', MixiAppInviteSummary::SUMMARY_WEEK])
    assert_not_nil(summary)
    assert_equal(summary.registed_mixi_user_count, 50) # 登録数
    assert_equal(summary.broadening_coefficient, 50/500.to_f) # 広がり係数=登録数/先週のアクティブUU
  end
  
  define_method('test: update_month は前月の招待数と広がり係数を履歴テーブルを更新する') do 
    MixiAppInvite.record_timestamps = false
    1.upto(100) do |i|
      invite_status = i % 2 == 0 ? 1 : 2
      MixiAppInvite.create({:mixi_user_id => 1, :invitee_user_id => i, :invite_status => invite_status,
                            :created_at => Time.now.last_month.beginning_of_month, :updated_at => Time.now.last_month.beginning_of_month})
    end
    MixiAppInvite.record_timestamps = true
    MixiActiveHistory.create(:history_day => Time.now.last_month.beginning_of_month.to_date, :user_count => 1000, :before_days => 30)
    
    assert_difference 'MixiAppInviteSummary.count', 1 do 
      worker = MixiAppInviteSummaryCreateWorker.new
      worker.update_month
    end
    
    summary = MixiAppInviteSummary.find(:first, :conditions => ['summary_type = ?', MixiAppInviteSummary::SUMMARY_MONTH])
    assert_not_nil(summary)
    assert_equal(summary.registed_mixi_user_count, 50) # 登録数
    assert_equal(summary.broadening_coefficient, 50/1000.to_f) # 広がり係数=登録数/先週のアクティブUU
  end
end