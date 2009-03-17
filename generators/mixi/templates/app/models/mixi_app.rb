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
end
