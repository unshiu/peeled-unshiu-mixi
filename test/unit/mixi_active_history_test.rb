require File.dirname(__FILE__) + '/../test_helper'

module MixiActiveHistoryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_active_histories
      end
    end
  end
  
  define_method('test: oldest_year は履歴の一番古い年度を取得する') do 
    assert_not_nil(MixiActiveHistory.oldest_year)
    
    MixiActiveHistory.create(:user_count => 1, :history_day => '1990-01-01', :before_days => 3)
    assert_equal(MixiActiveHistory.oldest_year, 1990)
  end
  
  define_method('test: oldest_year は履歴がない場合は履歴の一番古い年度は今年を返す') do 
    MixiActiveHistory.destroy_all
    
    assert_equal(MixiActiveHistory.oldest_year, Time.now.year)
  end
  
  define_method('test: newest_year は履歴の一番新しい年度を取得する') do 
    assert_not_nil(MixiActiveHistory.newest_year)
    
    MixiActiveHistory.create(:user_count => 1, :history_day => '2990-01-01', :before_days => 3)
    assert_equal(MixiActiveHistory.newest_year, 2990)
  end
  
  define_method('test: newest_year は履歴がない場合は履歴の一番新しい年度は今年を返す') do 
    MixiActiveHistory.destroy_all
    
    assert_equal(MixiActiveHistory.newest_year, Time.now.year)
  end
  
  define_method('test: period は指定期間中の履歴を返す') do
    histories = MixiActiveHistory.period("2008-01-01", "2010-12-31")
    
    assert_not_nil(histories)
    assert_not_equal(histories.size, 0)
    
    histories.each do |history| # 指定期間内であること
      assert(history.history_day >= Date.new(2008, 1, 1))
      assert(history.history_day <= Date.new(2010, 12, 31))
    end
  end
  
  define_method('test: by_year_period は指定年度の履歴を返す') do
    histories = MixiActiveHistory.by_year_period(2009)
    
    assert_not_nil(histories)
    assert_not_equal(histories.size, 0)
    
    histories.each do |history| # 指定期間内であること
      assert(history.history_day >= Date.new(2009, 1, 1))
      assert(history.history_day <= Date.new(2009, 12, 31))
    end
  end
  
end