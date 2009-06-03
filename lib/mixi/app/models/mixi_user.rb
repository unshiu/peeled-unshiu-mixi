# == Schema Information
#
# Table name: mixi_users
#
#  id            :integer(4)      not null, primary key
#  mixi_id       :string(255)     not null
#  base_user_id  :integer(4)      not null
#  nickname      :string(255)
#  profile_url   :string(255)
#  thumbnail_url :string(255)
#  deleted_at    :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  status        :integer(4)
#

#==　MixiFriendModule
#
# mixiのユーザ情報
#
module MixiUserModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        has_many :mixi_friend_ships, :foreign_key => 'mixi_user_id', :class_name => 'MixiFriend'
        has_many :mixi_friends, :through => :mixi_friend_ships, :source => :mixi_friend_shipped
        
        # -------------------------------------
        # constants
        # -------------------------------------
        # status
        const_set('STATUS_ACTIVE',            1) # 登録ユーザー
        const_set('STATUS_WITHDRAWAL',        2) # 自分で退会したユーザ
        const_set('STATUS_FORCED_WITHDRAWAL', 3) # 管理者により退会されたユーザ
        
      end
    end
  end
  
  module ClassMethods
    
    def create_or_update(data)
      user = self.find_or_create_by_mixi_id(data["mixi_id"])
      user.status = MixiUser::STATUS_ACTIVE
      user.update_attributes(data)
      user
    end

    # アプリを削除したユーザ数を返す
    def count_delete_mixi_users
      self.count_with_deleted(:conditions => ["status = ? ", MixiUser::STATUS_WITHDRAWAL])
    end

    def avg_invite_per_user
      results = MixiUser.find_by_sql(["select avg(count_mixi_user) as avg" +
                                     " from ( select count(mixi_app_invites.mixi_user_id) as count_mixi_user from mixi_app_invites " +
                                     "          where mixi_app_invites.deleted_at IS NULL OR mixi_app_invites.deleted_at > ? " + 
                                     "          group by mixi_user_id ) as t1 ", Time.now])
      avg = 0
      results.each { |result| avg = result.avg }
      avg.to_f
    end
    
  end
end
