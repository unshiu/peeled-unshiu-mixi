#== MixiApplicationControllerModule
# 
# mixi plugin を利用する際全アプリケーション的に必要なModule
#
module MixiApplicationControllerModule
  
private
  
  def validate_session
    @mixiapp_owner = MixiUser.find_by_mixi_id(params[:owner]) if params[:owner]
    @mixiapp_owner = session[:owner] if session[:owner]
    
    if @mixiapp_owner
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
    options[:owner] = @mixiapp_owner.mixi_id if @mixiapp_owner
    options[request.session_options[:key]] = request.session_options[:id]
    redirect_to(options, response_status)
  end
   
end