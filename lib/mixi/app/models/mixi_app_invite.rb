#==MixiAppInviteModule
#
# ユーザ招待情報
#
module MixiAppInviteModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
      end
    end
  end
end