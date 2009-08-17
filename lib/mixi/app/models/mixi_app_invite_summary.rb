module MixiAppInviteSummaryModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        const_set('SUMMARY_DAY',    "SUMMARY_DAY".hash.abs)
        const_set('SUMMARY_WEEK',   "SUMMARY_WEEK".hash.abs)
        const_set('SUMMARY_MONTH',  "SUMMARY_MONTH".hash.abs)
        
      end
    end
  end
  
  module ClassMethods    
  end
end