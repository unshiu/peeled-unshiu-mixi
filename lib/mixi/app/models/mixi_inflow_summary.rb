# == Schema Information
#
# Table name: mixi_inflow_summaries
#
#  id                       :integer(4)      not null, primary key
#  summary_type             :integer(4)      not null
#  start_at                 :datetime        not null
#  end_at                   :datetime        not null
#  inflow_mixi_user_count   :integer(4)      not null
#  registed_mixi_user_count :integer(4)      not null
#  mixi_inflow_master_id    :integer(4)      not null
#  deleted_at               :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

module MixiInflowSummaryModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :mixi_inflow_master
        
        const_set('SUMMARY_DAY',    "SUMMARY_DAY".hash.abs)
        const_set('SUMMARY_3_DAY',  "SUMMARY_3_DAY".hash.abs)
        const_set('SUMMARY_WEEK',   "SUMMARY_WEEK".hash.abs)
        const_set('SUMMARY_2_WEEK', "SUMMARY_2_WEEK".hash.abs)
        const_set('SUMMARY_MONTH',  "SUMMARY_MONTH".hash.abs)
        
        named_scope :days, :conditions => ["summary_type = ? ", MixiInflowSummary::SUMMARY_DAY]
        
        named_scope :total, :conditions => ["mixi_inflow_master_id = ? ", MixiInflowMaster::TOTAL] 
      end
    end
  end
  
  
  
  def conversion
    self.registed_mixi_user_count.to_f / self.inflow_mixi_user_count * 100 
  end
  
  module ClassMethods
  end
  
end
