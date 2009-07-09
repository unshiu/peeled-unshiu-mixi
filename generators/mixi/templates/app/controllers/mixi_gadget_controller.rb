class MixiGadgetController < MixiApplicationController
  include MixiGadgetControllerModule
  
  def top
    @mixi_user = current_mixiapp_viewer
    @batons = Baton.by_color(@baton_color).recent(8)
    @activities = MixiActivity.find(:all, :conditions => ['receipt_mixi_user_id = ?', @mixi_user.id], 
                                    :limit => 10, :order => 'created_at desc')
    @friends = @mixi_user.recent_baton_answer_friend_with_paginate(4, 0)
  end

end
