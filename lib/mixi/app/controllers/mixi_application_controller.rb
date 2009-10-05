#== MixiApplicationControllerModule
# 
# mixi plugin を利用する際全アプリケーション的に必要なModule
#
module MixiApplicationControllerModule

private
  
  # 現在そのアプリを閲覧しているユーザを返す
  def current_mixiapp_viewer
    session[:opensocial_viewer] ? session[:opensocial_viewer].dup : MixiUser.find_by_mixi_id(params[:opensocial_viewer_id])
  end
  
  # 現在そのアプリのガジェットを所有しているユーザを返す
  def current_mixiapp_owner
    session[:opensocial_owner] ? session[:opensocial_owner].dup : MixiUser.find_by_mixi_id(params[:opensocial_owner_id])
  end
  
  def validate_session
    if current_mixiapp_viewer
      true
    else
      respond_to do |format|
        format.html { redirect_to :controller => 'mixi_gadget', :action => 'timeout', :format => 'html' }
        format.js   { redirect_to :controller => 'mixi_gadget', :action => 'timeout', :format => 'js' }
      end
      false
    end
  end
  
  def redirect_mixi_gadget_to(options = {}, response_status = {})
    options[:opensocial_viewer_id] = current_mixiapp_viewer.mixi_id
    options[request.session_options[:key]] = request.session_options[:id]
    redirect_to(options, response_status)
  end
  
end
