# == Schema Information
#
# Table name: mixi_app_invites
#
#  id              :integer(4)      not null, primary key
#  mixi_app_id     :integer(4)      not null
#  mixi_user_id    :integer(4)      not null
#  invitee_user_id :integer(4)      not null
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class MixiAppInvite < ActiveRecord::Base
  include MixiAppInviteModule
end
