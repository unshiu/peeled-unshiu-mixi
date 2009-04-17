#== ManageMixiUsersControllerModule
# 
module ManageMixiUsersControllerModule
  
  def index
    @mixi_user_count = MixiUser.count
    @mixi_delete_user_count = MixiUser.count_delete_mixi_users
    @mixi_avg_invite_per_user = MixiUser.avg_invite_per_user
  end
  
end