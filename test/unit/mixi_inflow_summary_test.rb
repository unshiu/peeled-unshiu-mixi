require File.dirname(__FILE__) + '/../test_helper'

module MixiInflowSummaryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_users
        fixtures :mixi_inflows
        fixtures :mixi_inflow_masters
        fixtures :mixi_inflow_summaries
      end
    end
  end
  
  define_method('test: mixi_inflow_sumamry の関連') do
    mixi_inflow_summary = mixi_inflow_summaries(:day)
    
    assert_not_nil(mixi_inflow_summary.mixi_inflow_master)
  end
  
  define_method('test: conversion はその履歴のコンバージョン率を表示する') do
    mixi_inflow_summary = MixiInflowSummary.new
    mixi_inflow_summary.inflow_mixi_user_count = 1000
    mixi_inflow_summary.registed_mixi_user_count = 100
    assert_equal(mixi_inflow_summary.conversion, 10.0)
  end
  
  define_method('test: days は日ごとのコンバージョン率履歴を取得する') do
    mixi_inflow_summaries = MixiInflowSummary.days
    
    assert_not_nil(mixi_inflow_summaries)
    assert(mixi_inflow_summaries.size > 0)
    
    mixi_inflow_summaries.each do |mixi_inflow_summary|
      assert_equal(mixi_inflow_summary.summary_type, "SUMMARY_DAY".hash)
    end
  end
  
  define_method('test: total は日ごとの総数コンバージョン率履歴を取得する') do
    mixi_inflow_summaries = MixiInflowSummary.total
    
    assert_not_nil(mixi_inflow_summaries)
    assert(mixi_inflow_summaries.size > 0)
    
    mixi_inflow_summaries.each do |mixi_inflow_summary|
      assert_equal(mixi_inflow_summary.mixi_inflow_master.id, 1)
    end
  end
end