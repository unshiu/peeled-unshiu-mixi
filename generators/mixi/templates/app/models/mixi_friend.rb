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

class MixiFriend < ActiveRecord::Base
  include MixiFriendModule
end

