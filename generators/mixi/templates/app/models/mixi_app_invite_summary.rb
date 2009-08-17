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

class MixiAppInviteSummary < ActiveRecord::Base
  include MixiAppInviteSummaryModule
end
