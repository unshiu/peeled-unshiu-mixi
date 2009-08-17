#
# 管理画面での招待統計検索用form
#
module Forms
  module MixiAppInviteSummarySearchFormModule
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :start_year, :start_month, :start_day, :end_year, :end_month, :end_day
          attr_accessor :start_at, :end_at
          attr_accessor :type
          
          validates_presence_of :type
        end
      end
    end
    
    def initialize(params)
      ["start", "end"].each do |key|
        params["#{key}_year"] = params["#{key}_at(1i)"].to_i
        params["#{key}_month"] = params["#{key}_at(2i)"].to_i
        params["#{key}_day"] = params["#{key}_at(3i)"].to_i unless params["#{key}_at(3i)"].nil?
      end
      
      params = params.reject {|key, value| key =~ /(start|end)_at/ }
      super(params)
    end
    
    def start_date
      begin
        if day? || week?
          Time.mktime(@start_year, @start_month, @start_day, 0, 0, 0)  
        elsif month?
          Time.mktime(@start_year, @start_month, 1, 0, 0, 0)
        end
      rescue ArgumentError
        self.errors.add('date','存在しない日付です。')
        return nil
      end
    end
  
    def end_date
      begin
        if day? || week?
          Time.mktime(@end_year, @end_month, @end_day, 23, 59, 59)
        elsif month?
          Time.mktime(@end_year, @end_month, 1, 0, 0, 0) - 1
        end
      rescue ArgumentError
        self.errors.add('date','存在しない日付です。')
        return nil
      end
    end
  
    def day?
      @type == 'day' ? true : false
    end
  
    def week?
      @type == 'week' ? true : false
    end
    
    def month?
      @type == 'month' ? true : false
    end
    
    def summary_type
      if day?
        MixiAppInviteSummary::SUMMARY_DAY
      elsif week?
        MixiAppInviteSummary::SUMMARY_WEEK
      elsif month?
        MixiAppInviteSummary::SUMMARY_MONTH
      end
    end
  end
end