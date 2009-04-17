require File.dirname(__FILE__) + '/../test_helper'

module MixiActiveHistoryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_active_histories
      end
    end
  end
  
  define_method('test: 履歴の一番古い年度を取得する') do 
    assert_not_nil(MixiActiveHistory.oldest_year)
    
    MixiActiveHistory.create(:user_count => 1, :history_day => '1990-01-01')
    assert_equal(MixiActiveHistory.oldest_year, 1990)
  end
  
  define_method('test: 履歴がない場合は履歴の一番古い年度は今年を返す') do 
    MixiActiveHistory.destroy_all
    
    assert_equal(MixiActiveHistory.oldest_year, Time.now.year)
  end
  
  define_method('test: 履歴の一番新しい年度を取得する') do 
    assert_not_nil(MixiActiveHistory.newest_year)
    
    MixiActiveHistory.create(:user_count => 1, :history_day => '2990-01-01')
    assert_equal(MixiActiveHistory.newest_year, 2990)
  end
  
  define_method('test: 履歴がない場合は履歴の一番新しい年度は今年を返す') do 
    MixiActiveHistory.destroy_all
    
    assert_equal(MixiActiveHistory.newest_year, Time.now.year)
  end
  
  define_method('test: 指定期間中の履歴を返す') do
    histories = MixiActiveHistory.period("2008-01-01", "2010-12-31")
    
    assert_not_nil(histories)
    assert_not_equal(histories.size, 0)
    
    histories.each do |history| # 指定期間内であること
      assert(history.history_day >= Date.new(2008, 1, 1))
      assert(history.history_day <= Date.new(2010, 12, 31))
    end
  end
  
  define_method('test: 指定年度の履歴を返す') do
    histories = MixiActiveHistory.by_year_period(2009)
    
    assert_not_nil(histories)
    assert_not_equal(histories.size, 0)
    
    histories.each do |history| # 指定期間内であること
      assert(history.history_day >= Date.new(2009, 1, 1))
      assert(history.history_day <= Date.new(2009, 12, 31))
    end
  end
  
  define_method('test: 指定期間内の月別履歴を返す') do
    histories = MixiActiveHistory.summary_period_by_year_month("2008-01-01", "2011-12-31")
    
    assert_not_nil(histories)
    assert_not_equal(histories.size, 0)
    
    histories.each do |history| # 指定期間内であること
      assert(history.history_day >= Date.new(2008, 1, 1))
      assert(history.history_day <= Date.new(2010, 12, 31))
    end
  end
  
  define_method('test: 月別集計履歴を返す') do
    histories = MixiActiveHistory.summary_by_year_month(2009)
    
    assert_not_nil(histories)
    assert_not_equal(histories.size, 0)
    
    histories.each do |history| 
      assert_not_nil(history.user_count)
      assert_not_nil(history.history_day)
    end
    
    histories = MixiActiveHistory.summary_by_year_month(3009)
    
    assert_not_nil(histories)
    assert_equal(histories.size, 0) # 対象履歴がない
  end
  
  define_method('test: 年度別集計履歴を返す') do
    histories = MixiActiveHistory.summary_by_year
    
    assert_not_nil(histories)
    assert_not_equal(histories.size, 0)
    
    histories.each do |history| 
      assert_not_nil(history.user_count)
      assert_not_nil(history.history_day)
    end
  end
end