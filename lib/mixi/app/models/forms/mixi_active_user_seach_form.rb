#
# 管理画面でのmixiアクティブユーザ検索用form
#
module Forms
  module MixiActiveUserSearchFormModule
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :start_year, :start_month, :start_day, :end_year, :end_month, :end_day
          attr_accessor :type
          attr_accessor :csv, :show
          
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
        if day?
          Date.new(@start_year, @start_month, @start_day)
        elsif month?
          Date.new(@start_year, @start_month, 1)
        end
      rescue ArgumentError
        self.errors.add('date','存在しない日付です。')
        return nil
      end
    end
  
    def end_date
      begin
        if day?
          Date.new(@end_year, @end_month, @end_day)
        elsif month?
          Date.new(@end_year, @end_month, 1)
        end
      rescue ArgumentError
        self.errors.add('date','存在しない日付です。')
        return nil
      end
    end
  
    def day?
      @type == 'day' ? true : false
    end
  
    def month?
      @type == 'month' ? true : false
    end
    
    def csv?
      @csv.nil? ? false : true
    end
    
  end
end
