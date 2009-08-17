# == Schema Information
#
# Table name: mixi_inflow_masters
#
#  id         :integer(4)      not null, primary key
#  route_name :string(255)     not null
#  route_key  :string(255)     not null
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

class MixiInflowMaster < ActiveRecord::Base
  include MixiInflowMasterModule
  
end
