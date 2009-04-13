#==　MixiFriendModule
#
# mixi内での友達情報
#
module MixiFriendModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :bemixi_friend_shipped, :foreign_key=>:mixi_user_id, :class_name => "MixiUser"
        belongs_to :mixi_friend_shipped,   :foreign_key=>:friend_id,    :class_name => "MixiUser"
        
      end
    end
  end

end