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
  
  def after_create
    BatonAffinity.create({:mixi_user_id => self.mixi_user_id, :friend_user_id => self.friend_id, :baton_color_id => nil, :affinity => 0})
    
    BatonColor::EN_LIST.each do |color|
      BatonAffinity.create({:mixi_user_id => self.mixi_user_id, :friend_user_id => self.friend_id, :baton_color_id => color[0], :affinity => 0})
    end
  end
end

