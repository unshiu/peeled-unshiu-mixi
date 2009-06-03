#
# 管理画面でのmixiアクティブユーザ検索用form
#
module Forms
  module MixiActiveUserSearchFormModule
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :start_at, :end_at
          attr_accessor :type
          attr_accessor :csv, :show
          
          validates_presence_of :type
          # validates_date :start_at, :end_at # FIXME active_form だと validates_dateがきかない
        end
      end
    end
    
    def initialize(params)
      ["start_at", "end_at"].each do |key|
        params[key] = Date.new(params["#{key}(1i)"].to_i, params["#{key}(2i)"].to_i, params["#{key}(3i)"].to_i)
      end
      
      params = params.reject {|key, value| key =~ /(start|end)_at\(/ }
      super
    rescue ArgumentError
      self.errors.add('date', I18n.t('activerecord.errors.messages.date_invalid'))
      return nil
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
