# == Schema Information
#
# Table name: mixi_app_invites
#
#  id              :integer(4)      not null, primary key
#  mixi_user_id    :integer(4)      not null
#  invitee_user_id :integer(4)      not null
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  invite_status   :integer(4)
#

#==MixiAppInviteModule
#
# ユーザ招待情報
#
module MixiAppInviteModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        # -------------------------------------
        # constants
        # -------------------------------------
        # status
        const_set('INVITE_STATUS_INVITED',    1) # 招待済み
        const_set('INVITE_STATUS_INSTALLED',  2) # アプリインストール済み
        
        named_scope :installed, :conditions => ["invite_status = ?", MixiAppInvite::INVITE_STATUS_INSTALLED]
        
      end
    end
  end
  
  module ClassMethods
    
    # 招待済みユーザを作成する
    # _param1_:: attributes
    #　_see_ :: ActiveResource::Base.create
    def invited_create(attributes = {})
      attributes[:invite_status] = MixiAppInvite::INVITE_STATUS_INVITED
      create(attributes)
    end
  end
  
  
end
