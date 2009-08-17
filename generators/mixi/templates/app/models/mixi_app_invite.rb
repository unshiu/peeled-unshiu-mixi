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

class MixiAppInvite < ActiveRecord::Base
  include MixiAppInviteModule
end
