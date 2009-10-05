#== MixiGadgetControllerModule
# 
# gedget.xmlの表示や共通動作を行うModule
#
require 'json'

module MixiGadgetControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        protect_from_forgery :except => ["register_person", "register_friends", "register_friendships", "invite_register", "index", "top", "timeout"]
        layout 'mixi_gadget'
        before_filter :validate_session, :only => [:top]
      end
    end
  end
  
  def register_person
    owner_data = JSON.parse(params['drecom_mixiapp_owner']).with_indifferent_access
    viewer_data = JSON.parse(params['drecom_mixiapp_viewer']).with_indifferent_access

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

    MixiLatestLogin.update_latest_login(viewer.id)

    session[:opensocial_owner] = owner
    session[:opensocial_viewer] = viewer
    session[:valid] = nil
    session[:base_user] = viewer.base_user # point処理のため

  end

  def register_friends
    viewer_data = JSON.parse(params['drecom_mixiapp_viewer']).with_indifferent_access
    friends_data = JSON.parse(params['drecom_mixiapp_friends'])

    viewer = MixiUser.create_or_update(viewer_data)

    exist_mixi_users = MixiUser.find(:all, :conditions => ["mixi_id in (?)", _get_mixi_ids_by_json(friends_data)], :select => "id, mixi_id")
    to_create_mixi_ids = _get_mixi_ids_by_json(friends_data) - _get_mixi_ids_by_mixi_user(exist_mixi_users);
    friends_data.each do |friend_data|
      if to_create_mixi_ids.include?(friend_data["mixi_id"])
        user = MixiUser.create_or_update(friend_data)
        viewer.mixi_friends << user unless (user.nil? || viewer.mixi_friends.include?(user))
      end
    end
    viewer.save
  end

  # マイミク削除に対応するため，viewer_friends の mixi_id をすべて受け取って更新
  def register_friendships
    viewer_data = JSON.parse(params['drecom_mixiapp_viewer']).with_indifferent_access
    viewer_friend_mixi_ids = JSON.parse(params['drecom_mixiapp_friend_ids'])

    viewer = MixiUser.create_or_update(viewer_data)
    all_mixi_friends = MixiUser.find(:all, :conditions => ["mixi_id in (?)", viewer_friend_mixi_ids], :select => "id, mixi_id")

    viewer.mixi_friends = all_mixi_friends
    viewer.save
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
  
  private
  def _get_mixi_ids_by_json(friends_data)
    mixi_ids = []
    friends_data.each do |data|
      mixi_ids << data["mixi_id"]
    end
    return mixi_ids
  end
  def _get_mixi_ids_by_mixi_user(mixi_users)
    mixi_ids = []
    mixi_users.each do |mixi_user|
      mixi_ids << mixi_user.mixi_id
    end
    return mixi_ids
  end
end
