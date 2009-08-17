# == Schema Information
#
# Table name: mixi_inflows
#
#  id                    :integer(4)      not null, primary key
#  mixi_inflow_master_id :integer(4)      not null
#  referrer              :text
#  tracking_key          :string(255)
#  app_name              :string(255)
#  mixi_user_id          :integer(4)
#  registed_at           :datetime
#  deleted_at            :datetime
#  created_at            :datetime
#  updated_at            :datetime
#

class MixiInflow < ActiveRecord::Base
  include MixiInflowModule
  
end
