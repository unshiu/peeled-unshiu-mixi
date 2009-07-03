#== MixiApplicationControllerModule
# 
# mixi plugin を利用する際全アプリケーション的に必要なModule
#
module MixiApplicationControllerModule
  
private
  
  def current_mixiapp_viewer
    session[:viewer] ? session[:viewer] : MixiUser.find_by_mixi_id(params[:viewer])
  end
  
  def current_mixiapp_onwer
    session[:owner] ? session[:owner] : MixiUser.find_by_mixi_id(params[:owner])
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
    options[:viewer] = current_mixiapp_viewer
    options[request.session_options[:key]] = request.session_options[:id]
    redirect_to(options, response_status)
  end
   
end