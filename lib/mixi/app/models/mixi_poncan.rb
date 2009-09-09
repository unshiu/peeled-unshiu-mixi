#
# 広告配信システムPoncan
#
module MixiPoncanModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        attr_accessor :uid, :rid, :cash , :point, :status
        
        # -------------------------------------
        # constants
        # -------------------------------------
        # status
        const_set('STATUS_UNDEFINED', 0) 
        const_set('STATUS_ACCEPT',    1) 
        const_set('STATUS_REJECT',    2) 
        
        # response 
        const_set('RESPONSE_ERROR',   "0") 
        const_set('RESPONSE_SUCCESS', "1") 
        
      end
    end
  end
  
  def initialize(result_ping)
    @uid = result_ping[:uid]
    @rid = result_ping[:rid]
    @cash = result_ping[:cash].to_i
    @point = result_ping[:point].to_i
    @status = result_ping[:status].to_i
  end
  
  module ClassMethods
  end

end
