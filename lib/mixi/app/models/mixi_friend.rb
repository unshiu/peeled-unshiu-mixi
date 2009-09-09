# == Schema Information
#
# Table name: mixi_friends
#
#  id           :integer(4)      not null, primary key
#  mixi_user_id :integer(4)      not null
#  friend_id    :integer(4)      not null
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

#==　MixiFriendModule
#
# mixi内での友達情報
#
module MixiFriendModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :mixi_user
        belongs_to :friend_user, :foreign_key=>:friend_id, :class_name => "MixiUser"
        
      end
    end
  end

end
