require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/mixi_inflow_summary_create_worker"

module MixiInflowSummaryCreateWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_friends
        fixtures :mixi_inflows
        fixtures :mixi_inflow_masters
        fixtures :mixi_inflow_summaries
      end
    end
  end

  define_method('test: update_yesterday は前日の流入ユーザとコンバージョン率数を計算し、履歴テーブルを更新する') do 
    MixiInflowSummary.delete_all
    
    upcount = MixiInflow.count(:select => ['distinct(mixi_inflow_master_id)']) + 1 # totalは既存の履歴にはないから
    assert_difference 'MixiInflowSummary.count', upcount do 
      worker = MixiInflowSummaryCreateWorker.new
      worker.update_yesterday
    end
    
    inflow_master = mixi_inflow_masters(:blog)
    summary = MixiInflowSummary.find(:first, :conditions => ['summary_type = ? and mixi_inflow_master_id = ?', "SUMMARY_DAY".hash, inflow_master.id])
    assert_not_nil(summary)
    
    inflow_count = MixiInflow.count(:conditions => ['mixi_inflow_master_id = ? and created_at >= ? and created_at <= ?', 
                                                    inflow_master.id, Time.now.yesterday.beginning_of_day, Time.now])
    assert_equal(summary.inflow_mixi_user_count, inflow_count)
    registed_count = MixiInflow.count(:conditions => ['mixi_inflow_master_id = ? and registed_at >= ? and registed_at <= ?', 
                                                    inflow_master.id, Time.now.yesterday.beginning_of_day, Time.now])
    assert_equal(summary.registed_mixi_user_count, registed_count)
    
    # その日のトータル
    summary = MixiInflowSummary.find(:first, :conditions => ['summary_type = ? and mixi_inflow_master_id = ?', "SUMMARY_DAY".hash, MixiInflowMaster::TOTAL])
    assert_not_nil(summary)
    
    inflow_count = MixiInflow.count(:conditions => ['created_at >= ? and created_at <= ?', Time.now.yesterday.beginning_of_day, Time.now])
    assert_equal(summary.inflow_mixi_user_count, inflow_count)
    registed_count = MixiInflow.count(:conditions => ['registed_at >= ? and registed_at <= ?', Time.now.yesterday.beginning_of_day, Time.now])
    assert_equal(summary.registed_mixi_user_count, registed_count)
  end
  
  define_method('test: update_month は前月の流入ユーザとコンバージョン率数を計算し、履歴テーブルを更新する') do 
    MixiInflowSummary.delete_all
    
    upcount = MixiInflow.count(:select => ['distinct(mixi_inflow_master_id)']) + 1 # totalは既存の履歴にはないから
    assert_difference 'MixiInflowSummary.count', upcount do 
      worker = MixiInflowSummaryCreateWorker.new
      worker.update_month
    end
    
    inflow_master = mixi_inflow_masters(:blog)
    summary = MixiInflowSummary.find(:first, :conditions => ['summary_type = ? and mixi_inflow_master_id = ?', MixiInflowSummary::SUMMARY_MONTH, inflow_master.id])
    assert_not_nil(summary)
    
    inflow_count = MixiInflow.count(:conditions => ['mixi_inflow_master_id = ? and created_at >= ? and created_at <= ?', 
                                                    inflow_master.id, Time.now.last_month.beginning_of_month, Time.now.last_month.end_of_month])
    assert_equal(summary.inflow_mixi_user_count, inflow_count)
    registed_count = MixiInflow.count(:conditions => ['mixi_inflow_master_id = ? and registed_at >= ? and registed_at <= ?', 
                                                    inflow_master.id, Time.now.last_month.beginning_of_month, Time.now.last_month.end_of_month])
    assert_equal(summary.registed_mixi_user_count, registed_count)
    
    # その月のトータル
    summary = MixiInflowSummary.find(:first, :conditions => ['summary_type = ? and mixi_inflow_master_id = ?', MixiInflowSummary::SUMMARY_MONTH, MixiInflowMaster::TOTAL])
    assert_not_nil(summary)
    
    inflow_count = MixiInflow.count(:conditions => ['created_at >= ? and created_at <= ?', Time.now.last_month.beginning_of_month, Time.now.last_month.end_of_month])
    assert_equal(summary.inflow_mixi_user_count, inflow_count)
    registed_count = MixiInflow.count(:conditions => ['registed_at >= ? and registed_at <= ?', Time.now.last_month.beginning_of_month, Time.now.last_month.end_of_month])
    assert_equal(summary.registed_mixi_user_count, registed_count)
  end
end