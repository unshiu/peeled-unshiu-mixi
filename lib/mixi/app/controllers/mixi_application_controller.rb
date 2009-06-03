#== MixiApplicationControllerModule
# 
# mixi plugin を利用する際全アプリケーション的に必要なModule
#
module MixiApplicationControllerModule
  
protected

  def validate_session
    if !session[:owner]
      respond_to do |format|
        format.html { redirect_to :controller => 'mixi_gadget', :action => 'timeout', :format => 'html' }
        format.js   { redirect_to :controller => 'mixi_gadget', :action => 'timeout', :format => 'js' }
      end
      false
    else
      true
    end
 end
   
end