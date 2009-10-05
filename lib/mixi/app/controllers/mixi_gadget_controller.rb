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
    owner_data = JSON.parse(params['drecom_mixiapp_owner']).with_indifferent_access
    viewer_data = JSON.parse(params['drecom_mixiapp_viewer']).with_indifferent_access
    friends_data = JSON.parse(params['drecom_mixiapp_friends'])

    owner = MixiUser.create_or_update(owner_data)
    if owner.joined_at.nil?
      owner.joined_at = Time.now
      owner.save
    end

    if (owner.mixi_id == viewer_data["mixi_id"]) 
      viewer = owner
    else
      viewer = MixiUser.create_or_update(viewer_data)
    end

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
    
    MixiUser.delaying_setup(owner, friends)
  
    render :text => "register complete."
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
  
  def register_mobile
    owner_id = params[:opensocial_owner_id]
    h = MixiAPI::RESTHandler.new(owner_id)
    MixiAPI.register(nil, h.person, nil)
    MiddleMan.worker(:mixi_user_regist_worker).async_mixi_friends_register(:arg => { :viewer_id => owner_id, :rest_handler => h })
    
    redirect_to :action => 'top_mobile', :opensocial_owner_id => owner_id
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
  
  # モバイル版で最初に閲覧するページ。アプリ開発者がoverwriteして利用する
  def top_mobile
    # application overwrite
  end
  
end
