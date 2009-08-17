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

class MixiInflowSummary < ActiveRecord::Base
  include MixiInflowSummaryModule
end
