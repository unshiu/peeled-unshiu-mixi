# == Schema Information
# Schema version: 20090317064611
#
# Table name: mixi_apps
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     not null
#  key        :string(255)     not null
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

class MixiApp < ActiveRecord::Base
  acts_as_paranoid

  has_many :mixi_app_regists
  has_many :mixi_users, :through => :mixi_app_regists
  
  validates_presence_of :name, :key

  KEY_MAX_LENGTH = 32
  
  # ランダムで一意なキーを生成する
  def key_generate
    loop do
      key = Util.random_string(KEY_MAX_LENGTH)
      if MixiApp.find_by_key(key).nil?
        self.key = Util.random_string(KEY_MAX_LENGTH)
        break
      end
    end
  end

  # アプリを削除したユーザ数を返す
  def count_delete_mixi_users
    MixiAppRegist.count_with_deleted(:conditions => ["mixi_app_regists.mixi_app_id = ? and mixi_app_regists.deleted_at is not null", self.id])
  end
  
  def avg_invite_per_user
    results = MixiApp.find_by_sql(["select avg(count_mixi_user) as avg" +
                                   " from ( select count(mixi_app_invites.mixi_user_id) as count_mixi_user from mixi_app_invites " +
                                   "          where mixi_app_invites.mixi_app_id = ? and mixi_app_invites.deleted_at IS NULL OR mixi_app_invites.deleted_at > ? " + 
                                   "          group by mixi_user_id ) as t1 ", self.id, Time.now])
    avg = 0
    results.each { |result| avg = result.avg }
    avg.to_f
  end
  
end
