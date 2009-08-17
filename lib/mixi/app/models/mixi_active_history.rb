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
        
        validates_presence_of :before_days, :history_day, :user_count
        
        const_set('BEFORE_DAYS_LIST', { 1 => "前日", 3 => "３日", 7 => "１週間", 30 => "１ヶ月" })
        
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
    
  end

end
