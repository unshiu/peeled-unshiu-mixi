#== MixiGadgetControllerModule
# 
# gedget.xmlの表示や共通動作を行うModule
#
require 'json'

module MixiGadgetControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        protect_from_forgery :except => ["register", "invite_register", "index", "top", "timeout"]
        layout 'mixi_gadget'
        before_filter :validate_session, :only => [:top]
      end
    end
  end
  
  def register
    owner_data = JSON.parse(params['drecom_mixiapp_owner'])
    viewer_data = JSON.parse(params['drecom_mixiapp_viewer'])
    friends_data = JSON.parse(params['drecom_mixiapp_friends'])
    
    owner = MixiUser.create_or_update(owner_data)
    if owner.joined_at.nil?
      owner.joined_at = Time.now
      owner.save
    end
    viewer = MixiUser.create_or_update(viewer_data)
    
    friends = []
    friends_data.each do |friend_data|
      user = MixiUser.create_or_update(friend_data)
      unless user.nil?
        friends << user
        owner.mixi_friends << user unless owner.mixi_friends.member?(user)
      end
    end
    owner.save
    
    MixiLatestLogin.update_latest_login(viewer.id)
    
    owner = MixiUser.find(owner.id) # 関連情報がsessionにはいらないように
    viewer = MixiUser.find(viewer.id)
    session[:opensocial_owner] = owner
    session[:opensocial_viewer] = viewer
    session[:valid] = nil
    session[:base_user] = viewer.base_user # point処理のため
    
    MiddleMan.worker(:mixi_user_regist_worker).mixi_user_regist(:arg => {:mixi_user => owner, :mixi_friends => friends})
    
    if params[:history]
      history = params[:history].split(/\//)
      redirect_mixi_gadget_to :controller => history[0], :action => history[1]
    else
      redirect_mixi_gadget_to :controller => "mixi_gadget", :action => "top"
    end
  end
  
  def invite_register
    mixi_user_id = params[:drecom_mixiapp_inviteId]
    invite_data = JSON.parse(params['drecom_mixiapp_recipientIds'])
    
    invite_data.each do |invitee_user_id|
      MixiAppInvite.invited_create(:mixi_user_id => mixi_user_id, :invitee_user_id => invitee_user_id)
    end
    
    render :text => "OK"
  rescue => e
    logger.error "mixi inviate registe error \n #{e}"
    render :text => "NG"
  end
  
  def timeout
  end
  
  def index
    respond_to do |format|
      format.xml
    end
  end

  # gadgetが表示されて最初に閲覧するページ。アプリ開発者がoverwriteして利用する
  def top
    # application overwrite
  end
  
<<<<<<< HEAD:lib/mixi/app/controllers/mixi_gadget_controller.rb
private 
  
  def token_require
    @mixi_token = MixiToken.find_by_token(params[:mixi_token])
    if @mixi_token.nil? || @mixi_token.use_flag 
      redirect_to_error("U-10000")
    else
      @mixi_token.use_flag = true
      @mixi_token.save
      true
    end
=======
  # モバイル版で最初にアクセスされるページ。アプリ開発者がoverwriteして利用する
  def register_mobile
    # application overwrite
>>>>>>> 77aa914... iframeの方に定義されているのでいらない:lib/mixi/app/controllers/mixi_gadget_controller.rb
  end
  
end