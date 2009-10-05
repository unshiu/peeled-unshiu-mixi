# == Schema Information
#
# Table name: mixi_users
#
#  id            :integer(4)      not null, primary key
#  mixi_id       :string(255)     not null
#  base_user_id  :integer(4)
#  nickname      :string(255)
#  profile_url   :string(255)
#  thumbnail_url :string(255)
#  status        :integer(4)
#  joined_at     :datetime
#  quitted_at    :datetime
#  deleted_at    :datetime
#  created_at    :datetime
#  updated_at    :datetime
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
        
        has_many :mixi_friendships, :foreign_key => 'mixi_user_id', :class_name => 'MixiFriend'
        has_many :mixi_friends, :through => :mixi_friendships, :source => :friend_user
        
        belongs_to :base_user
        
        # -------------------------------------
        # constants
        # -------------------------------------
        # status
        const_set('STATUS_ACTIVE',            1) # 登録ユーザー
        const_set('STATUS_WITHDRAWAL',        2) # 自分で退会したユーザ
        const_set('STATUS_FORCED_WITHDRAWAL', 3) # 管理者により退会されたユーザ
        
        after_create :association_with_base_user
      end
    end
  end
  
  module ClassMethods
    
    # アプリユーザを作成する。
    # ただしixi公認ユーザであり、アプリの利用が許可されていないユーザの場合、idのみでそれ以外の情報が空で渡されるのでユーザ作成しない
    # ユーザを作成された場合はそのオブジェクトがかえり、作成されなかった場合はnilがかえる。
    # _param1_:: data 
    # return:: mixi_user　
    def create_or_update(data)
      return nil if data["nickname"].blank?
      user = self.find_or_create_by_mixi_id(data["mixi_id"])
      user.status = MixiUser::STATUS_ACTIVE
      user.update_attributes(data) 
      user
    end

    def count_owner
      self.count(:conditions => ["joined_at is not null"])
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
    
    # アプリを利用できるかどうか判別する。
    # mixi公認ユーザであり、アプリの利用が許可されていないユーザの場合、idのみでそれ以外の情報が空
    def app_use_allow?
      self.nickname.blank? ? false : true
    end
  end

private

  # 他のplugin関連を扱えるようにbase_userとの関連付けを行う
  def association_with_base_user
    base_user = BaseUser.create({:login => "mixi:#{self.mixi_id}", :email => "#{self.id}@dummy.unshiu.jp"})
    base_user.activate(Util.random_string(8), false)
    self.base_user_id = base_user.id
    self.save
  end
  
end
