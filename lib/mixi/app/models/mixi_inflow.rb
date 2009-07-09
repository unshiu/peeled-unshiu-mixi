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

module MixiInflowModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :mixi_inflow_master
        belongs_to :mixi_user
        
        validates_presence_of :mixi_inflow_master_id
        validates_uniqueness_of :tracking_key, :with_blank => true
      end
    end
  end
  
  module ClassMethods
  end
  
end
