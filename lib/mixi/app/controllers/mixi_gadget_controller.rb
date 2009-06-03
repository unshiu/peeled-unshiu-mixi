#== MixiGadgetControllerModule
# 
# gedget.xmlの表示や共通動作を行うModule
#
require 'json'

module MixiGadgetControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        protect_from_forgery :except => ["register"]
        layout 'mixi_gadget'
        before_filter :validate_session, :only => [:top]
      end
    end
  end
  
  def register
    if session[:valid]
      owner_data = JSON.parse(params['owner'])
      friends_data = JSON.parse(params['friends'])
      
      owner = MixiUser.create_or_update(owner_data)
      if owner.joined_at.nil?
        owner.joined_at = Time.now
        owner.save
      end
      
      friends_data.each do |friend_data|
        user = MixiUser.create_or_update(friend_data)
        owner.mixi_friends << user unless owner.mixi_friends.member?(user)
      end
      owner.save
      
      MixiLatestLogin.update_latest_login(owner.id)
      
      session[:owner] = owner
      session[:valid] = nil
      
      redirect_to :action => 'top', request.session_options[:key] => request.session_options[:id]
    else
      render :action => 'timeout'
    end
  end
  
  def timeout
  end
  
  def index
    session[:valid] = true
    respond_to do |format|
      format.xml
    end
  end

  # gadgetが表示されて最初に閲覧するページ。アプリ開発者がoverwriteして利用する
  def top
    # application overwrite
  end
  
end