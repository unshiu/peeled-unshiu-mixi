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

module MixiInflowMasterModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        has_many :mixi_inflows
        
        const_set('TOTAL', 1)
        const_set('OTHER', 2)
        
        validates_presence_of :route_name, :route_key
      end
    end
  end
  
  def inflow_mark_url
    "http://#{AppResources[:init][:application_domain]}/mixi_inflows/add?key=?#{self.route_key}"
  end
  
  module ClassMethods
  end
  
end
