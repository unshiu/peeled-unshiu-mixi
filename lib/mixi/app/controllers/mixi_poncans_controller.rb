#== MixiPoncansControllerModule
# 
# ポイント広告処理
#
module MixiPoncansControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        layout 'mixi_gadget'
        before_filter :poncan_authorized
        
      end
    end
  end
  
  # 成果通知を受け取るping指定先
  # poncanサーバ以外からのリクエストは受け付けない
  def receipt
    mixi_poncan = MixiPoncan.new(params)
    mixi_user = MixiUser.find_by_mixi_id(mixi_poncan.uid)
    
    if mixi_poncan.status == MixiPoncan::STATUS_ACCEPT
      PntPointSystem.pointregister(mixi_user.base_user_id, AppResources[:mixi][:poncan_point_master_id], mixi_poncan.point, 
                                   I18n.t('view.messages.poncan_history', :rid => mixi_poncan.rid))
    end
    
    render :text => "#{MixiPoncan::RESPONSE_SUCCESS}"
    
  rescue => e
    logger.error "mixi poncan receipt: #{e}" 
    render :text => "#{MixiPoncan::RESPONSE_ERROR}"
  end

private 
  
  def poncan_authorized
    if request.ip != AppResources[:mixi][:poncan_ip]
      redirect_to_error 'U-10001'
    end
  end
end