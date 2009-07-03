#== MixiGadgetControllerModule
# 
# gedget.xmlの表示や共通動作を行うModule
#
require 'json'

module MixiGadgetControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        protect_from_forgery :except => ["register", "index", "top", "timeout"]
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
    
    friends_data.each do |friend_data|
      user = MixiUser.create_or_update(friend_data)
      owner.mixi_friends << user unless owner.mixi_friends.member?(user)
    end
    owner.save
    
    MixiLatestLogin.update_latest_login(viewer.id)
    
    session[:owner] = MixiUser.find(owner.id)
    session[:viewer] = MixiUser.find(viewer.id)
    session[:valid] = nil
    
    if params[:history]
      history = params[:history].split(/\//)
      redirect_mixi_gadget_to :controller => history[0], :action => history[1]
    else
      redirect_mixi_gadget_to :controller => "mixi_gadget", :action => "top"
    end
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

end