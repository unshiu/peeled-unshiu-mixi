# == Schema Information
# Schema version: 20090317064611
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
#

class MixiUser < ActiveRecord::Base
  acts_as_paranoid

  has_many :mixi_app_regists
  has_many :mixi_apps, :through => :mixi_app_regists
  
end
