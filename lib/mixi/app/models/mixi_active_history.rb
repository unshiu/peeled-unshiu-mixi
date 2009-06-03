# == Schema Information
#
# Table name: mixi_active_histories
#
#  id          :integer(4)      not null, primary key
#  history_day :date
#  user_count  :integer(4)
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

module MixiActiveHistoryModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        named_scope :period, lambda { |start_day, end_day| 
          {:conditions => ['history_day >= ? and history_day <= ?', start_day, end_day] } 
        }
      end
    end
  end
  
  module ClassMethods
    
    # 履歴の中で一番古い年度を返す。履歴がない場合は当日の年度を返すものとする
    def oldest_year
      old_history = find(:first, :order => ["history_day asc"])
      old_history.nil? ? Date.today.year : old_history.history_day.year
    end
    
    # 履歴の中で一番新しい年度を返す。履歴がない場合は当日の年度を返すものとする
    def newest_year
      new_history = find(:first, :order => ["history_day desc"])
      new_history.nil? ? Date.today.year : new_history.history_day.year
    end
    
    # 指定年度の日別履歴を返す
    # _param1_:: year 
    def by_year_period(year)
      start_day = Date.new(year, 1, 1)
      end_day = Date.new(year, 12, 31)
      
      period(start_day, end_day)
    end
    
    # 指定範囲内の月別のアクティブ数集計数を返す
    # _param1_:: start_date Date
    # _param2_:: end_date Date
    def summary_period_by_year_month(start_date, end_date)
      query = "select history_day, sum(user_count) as user_count"
      query << " from mixi_active_histories"
      query << " where history_day >= '#{start_date}' and history_day <= '#{end_date}'"
      query << " group by extract(year_month from history_day)"
      find_by_sql([sanitize_sql(query)])
    end
    
    # 月別のアクティブ数集計数を返す
    # _param1_:: year なければ全体
    def summary_by_year_month(year)
      query = "select history_day, sum(user_count) as user_count"
      query << " from mixi_active_histories"
      query << " where year(history_day) = #{year}" unless year.nil?
      query << " group by extract(year_month from history_day)"
      find_by_sql([sanitize_sql(query)])
    end
    
    
    # 年度別のアクティブ数集計数を返す
    # _param1_:: year
    def summary_by_year
      find_by_sql(["select history_day, sum(user_count) as user_count 
                    from mixi_active_histories group by year(history_day)"])
    end
    
  end

end
