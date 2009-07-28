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
