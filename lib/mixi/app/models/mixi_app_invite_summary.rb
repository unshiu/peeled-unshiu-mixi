# == Schema Information
#
# Table name: mixi_app_invite_summaries
#
#  id                       :integer(4)      not null, primary key
#  summary_type             :integer(4)      not null
#  start_at                 :datetime        not null
#  end_at                   :datetime        not null
#  registed_mixi_user_count :integer(4)      not null
#  broadening_coefficient   :float           not null
#  deleted_at               :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

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
