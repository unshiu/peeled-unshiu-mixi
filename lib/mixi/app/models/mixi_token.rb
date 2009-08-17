# == Schema Information
#
# Table name: mixi_tokens
#
#  id         :integer(4)      not null, primary key
#  token      :string(255)
#  use_flag   :boolean(1)
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

module MixiTokenModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        validates_presence_of :token
        
      end
    end
  end
  
  module ClassMethods
    
  end
end
