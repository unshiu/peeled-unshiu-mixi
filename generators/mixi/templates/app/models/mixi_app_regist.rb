# == Schema Information
# Schema version: 20090317064611
#
# Table name: mixi_users_mixi_apps
#
#  id           :integer(4)      not null, primary key
#  mixi_user_id :integer(4)      not null
#  mixi_app_id  :string(255)     not null
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class MixiAppRegist < ActiveRecord::Base
  
  belongs_to :mixi_user
  belongs_to :mixi_app
  
end
